require_relative '../../hairballs'

Hairballs.add_plugin(:colorize_json) do |plugin|
  plugin.libraries %w[json colorize]

  plugin.when_used do
    class IRB::Irb
      alias_method :old_output_value, :output_value

      def output_value
        is_json = JSON.parse(@context.last_value) rescue nil

        if is_json
          printf @context.return_format, JSON.pretty_generate(JSON.parse(@context.last_value)).blue
        else
          old_output_value
        end
      end
    end
  end
end
