require_relative 'hairballs/ext/kernel_vputs'
require_relative 'hairballs/exceptions'
require_relative 'hairballs/theme'
require_relative 'hairballs/plugin'
require_relative 'hairballs/version'

# Home of the Hairballs DSL for defining and using Themes and Plugins.
class Hairballs
  class << self
    # @return [Hairballs::Theme]
    attr_reader :current_theme

    # @return [Array<Hairballs::Theme>]
    def themes
      @themes ||= []
    end

    # Builds a new Hairballs::Theme and adds it to the list of `.themes` that
    # can be used.
    #
    # @param name [Symbol] Name to give the new Theme.
    # @return [Theme]
    def add_theme(name)
      theme = Theme.new(name)
      yield theme
      themes << theme
      vputs "Added theme: #{name}"

      theme
    end

    # Tells IRB to use the Hairballs::Theme of +theme_name+.
    #
    # @param theme_name [Symbol] The name of the Theme to use/switch to.
    def use_theme(theme_name)
      switch_to = themes.find { |theme| theme.name == theme_name }
      fail ThemeUseFailure.new(theme_name) unless switch_to
      vputs "Switched to theme: #{theme_name}"

      switch_to.use!
      @current_theme = switch_to

      true
    end

    # All Hairballs::Plugins available to be loaded.
    #
    # @return [Array<Hairballs::Plugin>]
    def plugins
      @plugins ||= []
    end

    # All Hairballs::Plugins that have been loaded.
    #
    # @return [Array<Hairballs::Plugin>]
    def loaded_plugins
      @loaded_plugins ||= []
    end

    # Builds a new Hairballs::Plugin and adds it to thelist of `.plugins` that
    # can be used.
    #
    # @param name [Symbol]
    # @param options [Hash] Plugin-dependent options to define.  These get
    #   passed along the the Hairballs::Plugin object and are used as attributes
    #   of the plugin.
    def add_plugin(name, **options)
      plugin = Plugin.new(name, options)
      yield plugin
      plugins << plugin
      vputs "Added plugin: #{name}"

      plugin
    end

    # Searches for the Hairballs::Plugin by the +plugin_name+, then loads it.
    # Raises
    # @param plugin_name [Symbol]
    def load_plugin(plugin_name, **options)
      plugin_to_use = plugins.find { |plugin| plugin.name == plugin_name }
      fail PluginLoadFailure.new(plugin_name) unless plugin_to_use
      vputs "Using plugin: #{plugin_name}"

      plugin_to_use.use!(options)
      loaded_plugins << plugin_to_use

      true
    end

    # Name of the relative directory.
    #
    # @return [String]
    def project_name
      @project_name ||= File.basename(Dir.pwd)
    end

    # Is IRB getting loaded for a rails console?
    #
    # @return [Boolean]
    def rails?
      ENV['RAILS_ENV'] || defined? Rails
    end
  end
end
