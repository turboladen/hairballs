require 'rubygems/commands/install_command'
require 'hairballs/ext/kernel_vputs'
require 'fiber'

class Hairballs
  # Helpers specifying and requiring dependencies for Themes and Plugins.
  module LibraryHelpers
    # @param libs [Array<String>]
    def libraries(libs=nil)
      return @libraries if @libraries && libs.nil?

      @libraries = libs ? libs : yield([])
    end

    # Requires #libraries on load.  If they're not installed, install them.  If
    # it can't be installed, move on to the next.
    def require_libraries
      return if @libraries.nil?

      missing_dependencies = []

      @libraries.each do |lib|
        begin
          vrequire(lib)
        rescue LoadError
          # rubocop:disable Metrics/LineLength
          vputs "[**:#{@name}](#{lib}) Unable to require; adding to install list..."
          # rubocop:enable Metrics/LineLength
          missing_dependencies << lib
        end
      end

      requirer = new_dependency_requirer(dependency_installer)
      install_missing_dependencies(missing_dependencies, requirer).resume
    end

    # Path to the highest version of the gem with the given gem.
    #
    # @param [String] gem_name
    # @return [String] The path to the latest install of +gem_name+.
    def find_latest_gem(gem_name)
      the_gem = Dir.glob("#{Gem.dir}/gems/#{gem_name}-*")

      the_gem.empty? ? nil : the_gem.sort.last
    end

    # Add all gems in the global gemset to the $LOAD_PATH so they can be used
    # even in places like 'rails console'.
    #
    # TODO: Use #find_latest_gem for each of #libraries.
    def do_bundler_extending
      vputs "[**:#{@name}] #do_bundler_extending: #{@libraries}"

      if defined?(::Bundler)
        vputs "[**:#{@name}] #do_bundler_extending: Libraries: #{@libraries}"

        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          next unless @libraries.any? { |l| p.include?(l) }
          gem_path = "#{p}/lib"
          # rubocop:disable Metrics/LineLength
          vputs "[**:#{@name}] #do_bundler_extending: Adding to $LOAD_PATH: #{gem_path}"
          # rubocop:enable
          $LOAD_PATH.unshift(gem_path)
        end
      else
        vputs %([**:#{@name}] #do_bundler_extending: Bundler not defined. Skipping.)
      end
    end

    # Undo the stuff that was done in #do_bundler_extending.
    #
    # TODO: Use #find_latest_gem for each of #libraries.
    def undo_bundler_extending
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $LOAD_PATH.delete(gem_path)
        end
      else
        vputs %([**:#{@name}] Bundler not defined.  Skipping.)
      end
    end

    #--------------------------------------------------------------------------
    # Privates
    #--------------------------------------------------------------------------

    private

    # @param lib [String]
    def vrequire(lib)
      vputs "[**:#{@name}](#{lib}) Requiring library..."
      require lib
      vputs "[**:#{@name}](#{lib}) Successfully required library!"
    end

    # @param deps [Array<String>] Names of the gems to install.
    # @param source [Fiber]
    # @retrun [Fiber]
    def install_missing_dependencies(deps, source)
      Fiber.new do
        deps.each do |lib|
          vputs "[**:#{@name}] #install_missing_dependencies Main dep... #{lib}"
          source.resume(lib)
        end
      end
    end

    # @return [Fiber]
    def dependency_installer
      Fiber.new do |lib|
        loop do
          vputs "[**:#{@name}] #dependency_installer installing #{lib}"
          result = install_gem(lib)

          vputs "[**:#{@name}] #dependency_installer Gem install of #{lib} done."
          puts "Unable to install gem '#{lib}'. Moving on..." if result > 0

          lib = Fiber.yield
          vputs "[**:#{@name}] #dependency_installer yield result: #{lib}"
        end
      end
    end

    # @param lib [String]
    # @return [Fixnum] Exit code from the Gem::Commands::InstallCommand.
    def install_gem(lib)
      cmd = Gem::Commands::InstallCommand.new
      cmd.handle_options [lib]
      result = 0

      begin
        cmd.execute
      rescue Gem::SystemExitException, Gem::RemoteFetcher::FetchError => ex
        puts "Got exception during '#{lib}' install: #{ex.class}: #{ex.message}"
        result = ex.exit_code
      end

      result
    end

    # @param [Queue] installer
    # @return [Fiber]
    def new_dependency_requirer(installer)
      Fiber.new do |lib|
        loop do
          vputs "[**:#{@name}] #new_dependency_requirer resumed for #{lib}"
          installer.resume(lib)
          vputs "[**:#{@name}] #new_dependency_requirer requiring lib #{lib}"

          if Hairballs.config.rails?
            installed_gem = find_latest_gem(lib)
            vputs "[**:#{@name}] #new_dependency_requirer: Gem installed at #{installed_gem}"
            $LOAD_PATH.unshift("#{installed_gem}/lib")
          end

          begin
            require lib
          rescue LoadError => ex
            puts "Got exception during #{lib} require: #{ex}"
          end

          vputs %([**:#{@name}] #new_dependency_requirer yielding...)
          lib = Fiber.yield
        end
      end
    end
  end
end
