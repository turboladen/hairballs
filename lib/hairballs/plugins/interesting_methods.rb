require_relative '../../hairballs'

# Returns only the methods not present on basic Objects.
#
# @see http://stackoverflow.com/a/873371/172106
Hairballs.add_plugin(:interesting_methods) do |plugin|
  plugin.on_load do
    Object.class_eval do
      # @return [Array<Symbol>]
      def interesting_methods
        case self.class
        when Class
          public_methods.sort - Object.public_methods
        when Module
          public_methods.sort - Module.public_methods
        else
          public_methods.sort - Object.new.public_methods
        end
      end
    end
  end
end
