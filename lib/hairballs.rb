require_relative 'hairballs/ext/kernel_vputs'
require_relative 'hairballs/version'
require_relative 'hairballs/helpers'
require_relative 'hairballs/theme'
require_relative 'hairballs/plugin'

class Hairballs
  extend Helpers

  class << self
    def themes
      @themes ||= []
    end

    def add_theme(name)
      theme = Theme.new(name)
      yield theme
      themes << theme
      vputs "Added theme: #{name}"

      theme
    end

    def use_theme(theme_name)
      switch_to = themes.find { |theme| theme.name == theme_name }
      fail "Theme not found: :#{theme_name}." unless switch_to
      vputs "Using theme: #{theme_name}"

      switch_to.use!
    end

    # @return [Array<Hairballs::Plugin>]
    def plugins
      @plugins ||= []
    end

    # @param name [Symbol]
    def add_plugin(name, **options)
      plugin = Plugin.new(name, options)
      yield plugin
      plugins << plugin
      vputs "Added plugin: #{name}"

      plugin
    end

    # @param plugin_name [Symbol]
    def use_plugin(plugin_name, **options)
      plugin_to_use = plugins.find { |plugin| plugin.name == plugin_name }
      fail "Plugin not found: :#{plugin_name}." unless plugin_to_use
      vputs "Using plugin: #{plugin_name}"

      plugin_to_use.use!(options)
    end
  end
end
