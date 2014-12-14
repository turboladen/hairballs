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
      @preface = ''
      @return = ''
    end

    def i
      @i ? "#{@preface}#{@i}" : nil
    end

    def s
      @s ? "#{@preface}#{@s}" : nil
    end

    def c
      @c ? "#{@preface}#{@c}" : nil
    end

    def n
      @n ? "#{@preface}#{@n}" : nil
    end

    def preface(string=nil)
      return @preface if @preface && string.nil? && !block_given?

      status = ' '
      @preface = block_given? ? yield(status) : ''
    end

    def configuration
      puts "Setting up prompt..."

      prompt_values = {}
      prompt_values[:AUTO_INDENT] = @auto_indent
      prompt_values[:PROMPT_C] = c
      prompt_values[:PROMPT_I] = i
      prompt_values[:PROMPT_N] = n
      prompt_values[:PROMPT_S] = s
      prompt_values[:RETURN] = @return

      prompt_values
    end
  end
end
