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
