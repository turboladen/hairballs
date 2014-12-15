require_relative 'helpers'

class Hairballs
  class Plugin
    include Helpers

    attr_reader :name

    def initialize(name, **options)
      @name = name
      @irb_configuration = nil

      options.each do |k, v|
        define_singleton_method(k) do
          instance_variable_get("@#{k}".to_sym)
        end

        define_singleton_method("#{k}=") do |new_value|
          instance_variable_set("@#{k}".to_sym, new_value)
        end

        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    def when_used(&block)
      @when_used = block
    end

    def use!(**options)
      options.each do |k, v|
        send("#{k}=".to_sym, v)
      end

      require_libraries
      @when_used.call
    end
  end
end
