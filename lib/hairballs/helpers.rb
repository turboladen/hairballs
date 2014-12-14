class Hairballs
  module Helpers

    def libraries(libs=nil)
      return @libraries if @libraries && libs.nil? && !block_given?
      fail 'meow' if libs.nil? && !block_given?

      @libraries = block_given? ? yield : libs
    end

    # Require #libraries on load.  If they're not installed, install them.  If it
    # can't be installed, move on to the next.
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

    # Add all gems in the global gemset to the $LOAD_PATH so they can be used even
    # in places like 'rails console'.
    def do_bundler
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $:.unshift(gem_path)
        end
      end
    end

    # Undo the stuff that was done in #do_bundler
    def undo_bundler
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $:.delete(gem_path)
        end
      end
    end

    # Is IRB getting loaded for a rails console?
    #
    # @return [Boolean]
    def rails?
      ENV['RAILS_ENV'] || defined? Rails
    end

    # The libs to require on load.  If they're not installed, install them.
    #
    # @return [Array<String>]
    def libraries
      return @libraries if @libraries

      @libraries = %w[irb/completion irb/ext/save-history rdoc awesome_print wirble looksee]

      @libraries +=
        case RUBY_PLATFORM
        when /mswin32|mingw32/
          %w[win32console]
        when /darwin/
          %w[terminal-notifier]
          #[]
        else
          []
        end
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

    def ruby_preface(status=' ')
      #"【#{project_name} 】#{status} %03n:"
      #"❪#{project_name} ❫#{status} %03n:"
      #"❲#{project_name} ❳#{status} %03n:"
      #"❨#{project_name} ❩#{status} %03n:"
      #"⟨#{project_name}⟩#{status} %03n:"
      #"[#{project_name}]#{status} %03n:"
      #"⎡#{project_name}⎦#{status} %03n:"
      "⟪#{project_name}⟫#{status} %03n:"
    end

    # Set up the prompt for a Ruby (non-Rails) environment.
    def set_up_for_ruby

      IRB.conf[:PROMPT][:MY_PROMPT] = {
        AUTO_INDENT: true,
        PROMPT_I: "#{ruby_preface}%i> ",
        PROMPT_S: "#{ruby_preface}%i%l ",
        PROMPT_C: "#{ruby_preface('❊')}%i> ",
        PROMPT_N: "#{ruby_preface('✚')}%i > ",
        RETURN:   "  ➥ %s\n"            # prefixes output
      }

      IRB.conf[:PROMPT_MODE] = :MY_PROMPT
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
