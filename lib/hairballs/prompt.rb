class Hairballs
  class Prompt
    attr_accessor :auto_indent
    attr_writer :i
    attr_writer :s
    attr_writer :c
    attr_writer :n
    attr_writer :return

    def initialize
      @auto_indent = nil
      @return = ''
    end

    def i
      "#{@preface}#{@i}"
    end

    def s
      "#{@preface}#{@s}"
    end

    def c
      "#{@preface}#{@c}"
    end

    def n
      "#{@preface}#{@n}"
    end

    def irb_configuration
      puts "Setting up prompt..."

      prompt_values = {}
      prompt_values[:AUTO_INDENT] = @auto_indent if @auto_indent
      prompt_values[:PROMPT_C] = c unless c.empty?
      prompt_values[:PROMPT_I] = i unless i.empty?
      prompt_values[:PROMPT_N] = n unless n.empty?
      prompt_values[:PROMPT_S] = s unless s.empty?
      prompt_values[:RETURN] = @return if @return

      prompt_values
    end
  end
end
