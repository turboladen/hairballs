require_relative '../../hairballs'

Hairballs.add_plugin(:object_ri) do |plugin|
  plugin.libraries %w[rdoc]

  plugin.when_used do
    Object.class_eval do
      # Directly lifted from rbates/dotfiles!
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
