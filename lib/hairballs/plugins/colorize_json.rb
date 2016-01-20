require 'hairballs'

# When any value is returned by evaluating some Ruby, this will check if it is
# JSON (by parsing it).  If it's JSON-like, it will get formatted prettily and
# using the +color+ given when calling +Hairballs.load_plugin(:colorize_json)+.
#
# This *must* get used/loaded after the :wirble plugin to work.
#
# TODO: fix to work with using/loading before Wirble.
Hairballs.add_plugin(:colorize_json, color: :blue) do |plugin|
  plugin.libraries %w[json colorize]

  plugin.on_load do
    IRB::Irb.class_eval do
      alias_method :old_output_value, :output_value

      define_method :output_value do
        is_json = JSON.parse(@context.last_value) rescue nil

        if is_json
          vputs "[#{plugin.name}] Return value is JSON-like"
          the_json = JSON.pretty_generate(
            JSON.parse(@context.last_value)
          ).colorize(plugin.color)
          printf @context.return_format, the_json
        else
          old_output_value
        end
      end
    end
  end
end
