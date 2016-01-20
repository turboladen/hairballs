class Hairballs
  # Hairballs representation of IRB.conf[:PROMPT].  Method names here make
  # prompt types clearer.
  #
  # TODO: Make it nicer to define Pry prompts.
  class Prompt
    # @!attribute irb_prompt_options [r]
    #   After setting values using the Prompt's setter methods, this Hash will
    #   represent those values using keys that correlate to
    #   IRB.conf[:PROMPT][:MY_PROMPT].
    #
    #   @return [Hash]
    attr_reader :irb_prompt_options

    def initialize
      vputs 'Setting up prompt...'
      @irb_prompt_options = IRB.conf[:PROMPT][:NULL].dup
    end

    # Wrapper for setting IRB.conf[:PROMPT][:MY_PROMPT][:PROMPT_C].
    # The prompt for when statements wrap multiple lines.
    #
    # @param new_continued_statement [String]
    def continued_statement=(new_continued_statement)
      @irb_prompt_options[:PROMPT_C] = new_continued_statement
    end

    # @return [String]
    def continued_statement
      @irb_prompt_options[:PROMPT_C]
    end

    # Wrapper for setting IRB.conf[:PROMPT][:MY_PROMPT][:PROMPT_S].
    # The prompt for when strings wrap multiple lines.
    #
    # @param new_continued_string [String]
    def continued_string=(new_continued_string)
      @irb_prompt_options[:PROMPT_S] = new_continued_string
    end

    # @return [String]
    def continued_string
      @irb_prompt_options[:PROMPT_S]
    end

    # Wrapper for setting IRB.conf[:PROMPT][:MY_PROMPT][:PROMPT_N].
    # The prompt for when statements include indentation.
    #
    # @param new_indented_code [String]
    def indented_code=(new_indented_code)
      @irb_prompt_options[:PROMPT_N] = new_indented_code
    end

    # @return [String]
    def indented_code
      @irb_prompt_options[:PROMPT_N]
    end

    # Wrapper for setting IRB.conf[:PROMPT][:MY_PROMPT][:PROMPT_I].
    #
    # @param new_normal [String]
    def normal=(new_normal)
      @irb_prompt_options[:PROMPT_I] = new_normal
    end

    # @return [String]
    def normal
      @irb_prompt_options[:PROMPT_I]
    end

    # Wrapper for setting IRB.conf[:PROMPT][:MY_PROMPT][:RETURN]. The prompt
    # for how to display return values.
    #
    # @param new_return_format [String]
    def return_format=(new_return_format)
      @irb_prompt_options[:RETURN] = new_return_format
    end

    # @return [String]
    def return_format
      @irb_prompt_options[:RETURN]
    end
  end
end
