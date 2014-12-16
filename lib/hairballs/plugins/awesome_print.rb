require_relative '../../hairballs'

Hairballs.add_plugin(:awesome_print) do |plugin|
  plugin.libraries %w(awesome_print)

  plugin.on_load do
    AwesomePrint.irb!
  end
end
