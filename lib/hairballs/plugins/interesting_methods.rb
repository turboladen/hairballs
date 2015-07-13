require 'hairballs'

# Returns only the methods not present on basic Objects.
#
# @see http://stackoverflow.com/a/873371/172106
Hairballs.add_plugin(:interesting_methods) do |plugin|
  plugin.on_load do
    Object.class_eval do
      # @return [Array<Symbol>]
      def interesting_methods
        other_methods = case self.class
                        when Class then Object.public_methods
                        when Module then Module.public_methods
                        else Object.new.public_methods
                        end

        (public_methods.sort - other_methods).uniq
      end
    end
  end
end
