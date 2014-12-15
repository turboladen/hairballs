require_relative 'hairballs/version'
require_relative 'hairballs/helpers'
require_relative 'hairballs/theme'
require_relative 'hairballs/plugin'

class Hairballs
  extend Helpers

  def self.themes
    @themes ||= []
  end

  def self.add_theme(name)
    theme = Theme.new(name)
    yield theme
    themes << theme

    theme
  end

  def self.use_theme(theme_name)
    switch_to = themes.find { |theme| theme.name == theme_name }
    fail "Theme not found: :#{theme_name}." unless switch_to

    switch_to.use!
  end

  # @return [Array<Hairballs::Plugin>]
  def self.plugins
    @plugins ||= []
  end

  # @param name [Symbol]
  def self.add_plugin(name, **options)
    plugin = Plugin.new(name, options)
    yield plugin
    plugins << plugin

    plugin
  end

  # @param plugin_name [Symbol]
  def self.use_plugin(plugin_name, **options)
    plugin_to_use = plugins.find { |plugin| plugin.name == plugin_name }
    fail "Plugin not found: :#{plugin_name}." unless plugin_to_use

    plugin_to_use.use!(options)
  end
end
