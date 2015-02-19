require 'hairballs'

# Directly lifted from rbates/dotfiles!  Adds +#ri+ to all Objects, letting you
# get ri docs from within your IRB session.
Hairballs.add_plugin(:object_ri) do |plugin|
  plugin.libraries %w(rdoc)

  plugin.on_load do
    Object.class_eval do
      def ri(method=nil)
        unless method && method =~ /^[A-Z]/ # if class isn't specified
          klass = self.kind_of?(Class) ? name : self.class.name
          method = [klass, method].compact.join('#')
        end

        system 'ri', method.to_s
      end
    end
  end
end
