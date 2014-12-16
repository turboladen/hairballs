require_relative '../../hairballs'

# Just loads Wirble.
Hairballs.add_plugin(:wirble) do |plugin|
  plugin.libraries %w(wirble)

  plugin.on_load do
    Wirble.init
    Wirble.colorize
  end
end
