require_relative '../../hairballs'

Hairballs.add_plugin(:interesting_methods) do |plugin|
  plugin.when_used do
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
    end
  end
end
