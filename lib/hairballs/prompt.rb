class Hairballs
  # Hairballs representation of IRB.conf[:PROMPT].  Method names here make
  # prompt types clearer.
  class Prompt
    # @param [Boolean]
    attr_accessor :auto_indent

    # The normal prompt string.  Same as
    # IRB.conf[:PROMPT][ prompt name ][:PROMPT_I]
    #
    # @param [String]
    attr_accessor :normal
    alias_method :i, :normal
    alias_method :i=, :normal=

    # The prompt for when strings wrap multiple lines.  Same as
    # IRB.conf[:PROMPT][ prompt name ][:PROMPT_S]
    #
    # @param [String]
    attr_accessor :continued_string
    alias_method :s, :continued_string
    alias_method :s=, :continued_string=

    # The prompt for when statements wrap multiple lines.  Same as
    # IRB.conf[:PROMPT][ prompt name ][:PROMPT_C]
    #
    # @param [String]
    attr_accessor :continued_statement
    alias_method :c, :continued_statement
    alias_method :c=, :continued_statement=

    # The prompt for when statements include indentation.  Same as
    # IRB.conf[:PROMPT][ prompt name ][:PROMPT_N]
    #
    # @param [String]
    attr_accessor :indented_code
    alias_method :n, :indented_code
    alias_method :n=, :indented_code=

    # The prompt for return values.  Same as
    # IRB.conf[:PROMPT][ prompt name ][:RETURN]
    #
    # @param [String]
    attr_accessor :return_format

    def initialize
      @auto_indent = nil
      @return_format = ''
    end

    # @return [Hash] A set of key/value pairs that can be used to pass to a
    #   IRB.conf[:PROMPT][ prompt name ].
    def irb_configuration
      vputs 'Setting up prompt...'

      prompt_values = {}
      prompt_values[:AUTO_INDENT] = @auto_indent if @auto_indent
      prompt_values[:PROMPT_C] = continued_statement unless continued_statement.empty?
      prompt_values[:PROMPT_I] = normal unless normal.empty?
      prompt_values[:PROMPT_N] = indented_code unless indented_code.empty?
      prompt_values[:PROMPT_S] = continued_string unless continued_string.empty?
      prompt_values[:RETURN] = @return_format if @return_format

      prompt_values
    end
  end
end
