require_relative 'helpers'
require_relative 'prompt'

class Hairballs
  class Theme
    include Hairballs::Helpers

    attr_accessor :name

    def initialize(name)
      @name = name
      @prompt = Prompt.new
    end

    def use!
      IRB.conf[:PROMPT][irb_name] = @prompt.configuration
      puts "IRB conf: #{IRB.conf[:PROMPT][irb_name]}"

      require_libraries
      puts "Done requiring."
      puts "Setting prompt mode to #{irb_name}"
      IRB.conf[:PROMPT_MODE] = irb_name
    end

    def irb_name
      @name.to_s.upcase
    end

    def prompt
      block_given? ? yield(@prompt) : @prompt
    end
  end
end
