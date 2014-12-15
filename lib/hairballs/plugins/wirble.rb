require_relative '../../hairballs'

Hairballs.add_plugin(:wirble) do |plugin|
  plugin.libraries %w[wirble]

  plugin.when_used do
    Wirble.init
    Wirble.colorize
  end
end
