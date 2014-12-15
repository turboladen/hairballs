require_relative '../../hairballs'

Hairballs.add_plugin(:awesome_print) do |plugin|
  plugin.libraries %w[awesome_print]

  plugin.when_used do
    AwesomePrint.irb!
  end
end
