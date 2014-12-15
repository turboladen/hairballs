require_relative '../../hairballs'

# Just loads Wirble.
Hairballs.add_plugin(:wirble) do |plugin|
  plugin.libraries %w(wirble)

  plugin.when_used do
    Wirble.init
    Wirble.colorize
  end
end
