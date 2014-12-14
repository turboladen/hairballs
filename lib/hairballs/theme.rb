require_relative 'helpers'
require_relative 'prompt'

class Hairballs
  class Theme
    include Hairballs::Helpers

    attr_accessor :name

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
      IRB.conf[:PROMPT][irb_name] = @prompt.configuration
      puts "IRB conf: #{IRB.conf[:PROMPT][irb_name]}"

      require_libraries
      puts "Done requiring."
      puts "Setting prompt mode to #{irb_name}"
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
  end
end
