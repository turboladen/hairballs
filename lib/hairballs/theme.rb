require_relative 'helpers'
require_relative 'prompt'

class Hairballs
  class Theme
    include Hairballs::Helpers

    attr_accessor :name
    attr_accessor :extend_bundler

    # @param name [Symbol]
    def initialize(name)
      @name = name
      @prompt = Prompt.new
    end

    # @param libs [Array<String>]
    def libraries(libs=nil)
      return @libraries if @libraries && libs.nil? && !block_given?

      if libs.nil? && !block_given?
        fail ArgumentError, "Must either provide an Array or a block."
      end

      @libraries = if block_given?
        libs = yield

        unless libs.kind_of?(Array)
          fail ArgumentError, "Block must return an Array."
        end

        libs
      else
        libs
      end
    end

    # Requires #libraries on load.  If they're not installed, install them.  If
    # it can't be installed, move on to the next.
    def require_libraries
      @libraries.each do |lib|
        retry_count = 0

        begin
          next if retry_count == 2
          puts "Requiring library: #{lib}"
          require lib
        rescue LoadError
          puts "#{lib} not installed; installing now..."
          Gem.install lib
          require lib
          retry_count += 1
          retry
        end
      end
    end

    def use!
      IRB.conf[:PROMPT][irb_name] = @prompt.irb_configuration
      do_bundler_extending if @extend_bundler
      require_libraries
      IRB.conf[:PROMPT_MODE] = irb_name
    end

    # @return [Symbol]
    def irb_name
      @name.to_s.upcase
    end

    # @return [Hairballs::Prompt]
    def prompt
      block_given? ? yield(@prompt) : @prompt
    end

    #---------------------------------------------------------------------------
    # PRIVATES
    #---------------------------------------------------------------------------

    private

    # Add all gems in the global gemset to the $LOAD_PATH so they can be used even
    # in places like 'rails console'.
    def do_bundler_extending
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $:.unshift(gem_path)
        end
      else
        puts 'Bundler not defined.  Skipping.'
      end
    end

    # Undo the stuff that was done in #do_bundler_extending.
    def undo_bundler_extending
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $:.delete(gem_path)
        end
      else
        puts 'Bundler not defined.  Skipping.'
      end
    end
  end
end
