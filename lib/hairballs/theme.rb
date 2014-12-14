require_relative 'helpers'

class Hairballs
  class Theme
    include Hairballs::Helpers

    attr_accessor :auto_indent
    attr_accessor :prompt_i
    attr_accessor :prompt_s
    attr_accessor :prompt_c
    attr_accessor :prompt_n
    attr_accessor :return
    attr_accessor :name

    def initialize(name)
      @name = name
      @auto_indent = nil
    end

    def use!
      set_up_prompt
      puts "IRB conf: #{IRB.conf[:PROMPT][irb_name]}"
      require_libraries
      puts "Done requiring."
      puts "Setting prompt mode to #{irb_name}"
      IRB.conf[:PROMPT_MODE] = irb_name
    end

    def irb_name
      @name.to_s.upcase
    end

    def set_up_prompt
      puts "Setting up prompt..."
      IRB.conf[:PROMPT][irb_name] = {
        AUTO_INDENT: @auto_indent,
        PROMPT_C: @prompt_c,
        PROMPT_I: @prompt_i,
        PROMPT_N: @prompt_n,
        PROMPT_S: @prompt_s,
        RETURN: @return
      }
      puts "Done.  #{IRB.conf[:PROMPT][irb_name]}"
    end
  end
end
