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

      @libraries.each do |lib|
        retry_count = 0

        begin
          next if retry_count == 2
          vputs "Requiring library: #{lib}"
          require lib
        rescue LoadError
          puts "#{lib} not installed; installing now..."
          Gem.install lib

          if Hairballs.rails?
            installed_gem = find_latest_gem(lib)
            $LOAD_PATH.unshift("#{installed_gem}/lib")
          end

          require lib
          retry_count += 1
          retry
        end
      end
    end

    # Path to the highest version of the gem with the given gem.
    #
    # @param [String] gem_name
    # @return [String]
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
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $LOAD_PATH.unshift(gem_path)
        end
      else
        vputs 'Bundler not defined.  Skipping.'
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
        vputs 'Bundler not defined.  Skipping.'
      end
    end
  end
end
