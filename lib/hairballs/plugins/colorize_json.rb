require_relative '../../hairballs'

# This *must* get used/loaded after the :wirble plugin to work.
#
# TODO: fix to work with using/loading before Wirble.
Hairballs.add_plugin(:colorize_json) do |plugin|
  plugin.libraries %w[json colorize]

  plugin.when_used do
    IRB::Irb.class_eval do
      alias_method :old_output_value, :output_value

      def output_value
        is_json = JSON.parse(@context.last_value) rescue nil

        if is_json
          vputs 'return value is JSON-like'
          printf @context.return_format, JSON.pretty_generate(JSON.parse(@context.last_value)).blue
        else
          old_output_value
        end
      end
    end
  end
end
