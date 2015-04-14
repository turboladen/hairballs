class Hairballs
  # Used when Hairballs tries to load a plugin, but the plugin cannot be found.
  class PluginNotFound < RuntimeError
    def initialize(plugin_name)
      message = "Plugin not found: :#{plugin_name}."
      super(message)
    end
  end

  # Used when Hairballs tries to load plugin, but the plugin could not be
  # loaded.
  class PluginLoadFailure < RuntimeError
    def initialize(plugin_name)
      message = "Unable to load plugin: :#{plugin_name}."
      super(message)
    end
  end

  # Used when Hairballs tries to load theme, but the theme could not be loaded.
  class ThemeUseFailure < RuntimeError
    def initialize(theme_name)
      message = "Theme not found: :#{theme_name}."
      super(message)
    end
  end
end
