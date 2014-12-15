class Hairballs
  module Helpers

    # Is IRB getting loaded for a rails console?
    #
    # @return [Boolean]
    def rails?
      ENV['RAILS_ENV'] || defined? Rails
    end

    # Name of the relative directory.
    #
    # @return [String]
    def project_name
      @project_name ||= File.basename(Dir.pwd)
    end

    # Set up the prompt for a Rails environment.
    def set_up_for_rails
      do_bundler

      IRB.conf[:PROMPT][:RAILS] = {
        AUTO_INDENT: true,
        PROMPT_I: "#{project_name}> ",    # normal prompt
        PROMPT_S: "#{project_name}✹ ",    # prompt when continuing a string
        PROMPT_C: "#{project_name}✚ ",    # prompt when continuing a statement
        RETURN:   "➥ %s\n"            # prefixes output
      }

      IRB.conf[:PROMPT_MODE] = :RAILS
      IRB.conf[:AUTO_INDENT] = true
    end

    def set_up_irb_history
      IRB.conf[:SAVE_HISTORY] = 1000
      IRB.conf[:EVAL_HISTORY] = 20
    end

    # Do the wirble things.
    def init_wirble
      if defined? Wirble
        Wirble.init
        Wirble.colorize
      end
    end

    # Do the awesome_print things.
    def init_awesome_print
      if defined? AwesomePrint
        AwesomePrint.irb!

        IRB::Irb.class_eval do
          def output_value
            require 'json'
            is_json = JSON.parse(@context.last_value) rescue nil

            if is_json
              puts JSON.pretty_generate(JSON.parse(@context.last_value)).blue
              #puts JSON.pretty_generate(@context.last_value).blue
            elsif @context.respond_to? :to_sym
              ap @context.last_value
            else
              ap @context.last_value
              #puts @context.last_value
            end
          end
        end
      end
    end

    def inject_helper_methods
      #class Object
      Object.class_eval do
        def interesting_methods
          case self.class
          when Class
            self.public_methods.sort - Object.public_methods
          when Module
            self.public_methods.sort - Module.public_methods
          else
            self.public_methods.sort - Object.new.public_methods
          end
        end

        def ri(method = nil)
          unless method && method =~ /^[A-Z]/ # if class isn't specified
            klass = self.kind_of?(Class) ? name : self.class.name
            method = [klass, method].compact.join('#')
          end
          system 'ri', method.to_s
        end
      end
    end
  end
end
