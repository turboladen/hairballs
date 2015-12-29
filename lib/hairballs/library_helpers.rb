require 'hairballs/ext/kernel_vputs'

class Hairballs
  # Helpers specifying and requiring dependencies for Themes and Plugins.
  module LibraryHelpers
    # @param libs [Array<String>]
    def libraries(libs=nil)
      return @libraries if @libraries && libs.nil?

      @libraries = if libs
                     libs
                   else
                     yield([])
                   end
    end

    # Requires #libraries on load.  If they're not installed, install them.  If
    # it can't be installed, move on to the next.
    def require_libraries
      return if @libraries.nil?

      install_threads = []
      require_threads = []
      require_queue = Queue.new

      @libraries.each do |lib|
        begin
          vputs "[**:#{@name}](#{lib}) Requiring library..."
          require lib
          vputs "[**:#{@name}](#{lib}) Successfully required library!"
        rescue LoadError
          puts "#{lib} not installed; installing now..."
          install_threads << start_install_thread(lib, require_queue)
          require_threads << start_require_thread(require_queue)
        end
      end
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
      if defined?(::Bundler)
        vputs "[**:#{@name}] Libraries: #{@libraries}"
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          vputs "[**:#{@name}] Adding to $LOAD_PATH: #{gem_path}"
          $LOAD_PATH.unshift(gem_path)
        end
      else
        vputs %[[**:#{@name}] Bundler not defined.  Skipping.]
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
        vputs %[[**:#{@name}] Bundler not defined.  Skipping.]
      end
    end

    #--------------------------------------------------------------------------
    # Privates
    #--------------------------------------------------------------------------

    private

    # @param [String] lib Gem to install.
    # @param [Queue] require_queue Queue to push library names onto so the
    #   require thread can do its requiring.
    # @return [Thread]
    def start_install_thread(lib, require_queue)
      Thread.new do
        result = Gem.install(lib)

        if result.empty?
          puts "Unable to install gem '#{lib}'. Moving on..."
        else
          require_queue << lib
        end
      end
    end

    # @param [Queue] require_queue
    # @return [Thread]
    def start_require_thread(require_queue)
      Thread.new do
        lib = require_queue.pop

        if Hairballs.config.rails?
          installed_gem = find_latest_gem(lib)
          $LOAD_PATH.unshift("#{installed_gem}/lib")
        end

        require lib
      end.join
    end
  end
end
