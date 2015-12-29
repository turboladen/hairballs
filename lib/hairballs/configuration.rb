require 'open3'
require 'pathname'
require 'ostruct'
require 'hairballs/ext/kernel_vputs'
require 'hairballs/exceptions'
require 'hairballs/theme'
require 'hairballs/plugin'
require 'hairballs/version'

class Hairballs
  # The base-level +Hairballs+ class maintains an object of this type, which
  # contains the current configuration.
  class Configuration
    # @return [Array<Hairballs::Theme>]
    attr_reader :themes

    # @return [Hairballs::Theme]
    attr_reader :current_theme

    # All Hairballs::Plugins available to be loaded.
    #
    # @return [Array<Hairballs::Plugin>]
    attr_reader :plugins

    # All Hairballs::Plugins that have been loaded.
    #
    # @return [Array<Hairballs::Plugin>]
    attr_reader :loaded_plugins

    # Used for maintaining all possible completion Procs, thus allowing many
    # different plugins to define a Proc for completion without overriding Procs
    # defined for other plugins.
    #
    # @return [Array<Proc>]
    attr_reader :completion_procs

    # @return [String]
    attr_reader :project_name

    def initialize
      @themes = []
      @current_theme = nil
      @plugins = []
      @loaded_plugins = []
      @completion_procs = []
      @project_name = nil
      @project_root = nil
    end

    # @return [String]
    def version
      Hairballs::VERSION
    end

    # Is IRB getting loaded for a Rails console?
    #
    # @return [Boolean]
    def rails?
      ENV.key?('RAILS_ENV') || Kernel.const_defined?(:Rails)
    end

    # Name of the project, if it can be determined. If not, defaults to "irb".
    #
    # @return [String]
    def project_name
      @project_name ||= project_root ? project_root.basename.to_s : nil
    end

    # @return [Pathname]
    def project_root
      @project_root ||= find_project_root
    end

    # @param [String] path
    # @return [Boolean]
    def project_root?(path)
      File.expand_path(path) == project_root
    end

    # Builds a new Hairballs::Theme and adds it to the list of `.themes` that
    # can be used.
    #
    # @param [Symbol] name Name to give the new Theme.
    # @return [Theme]
    def add_theme(name)
      theme = Theme.new(name)

      yield theme

      themes << theme
      vputs "[config] Added theme: #{name}"

      theme
    end

    # Tells IRB to use the Hairballs::Theme of +theme_name+.
    #
    # @param [Symbol] theme_name The name of the Theme to use/switch to.
    def use_theme(theme_name)
      switch_to = themes.find { |theme| theme.name == theme_name }
      fail ThemeUseFailure, theme_name unless switch_to
      vputs "[config] Switched to theme: #{theme_name}"

      switch_to.use!
      @current_theme = switch_to

      true
    end

    # Builds a new Hairballs::Plugin and adds it to thelist of `.plugins` that
    # can be used.
    #
    # @param [Symbol] name
    # @param [Hash] options Plugin-dependent options to define.  These get
    #   passed along the the Hairballs::Plugin object and are used as attributes
    #   of the plugin.
    def add_plugin(name, **options)
      vputs "[config] Adding plugin: #{name}"
      plugin = Plugin.new(name, options)
      yield plugin
      plugins << plugin
      vputs "[config] Added plugin: #{name}"

      plugin
    end

    # Searches for the Hairballs::Plugin by the +plugin_name+, then loads it.
    # Raises
    # @param plugin_name [Symbol]
    def load_plugin(plugin_name, **options)
      plugin_to_use = plugins.find { |plugin| plugin.name == plugin_name }
      fail PluginNotFound, plugin_name unless plugin_to_use
      vputs "[config] Using plugin: #{plugin_name}"

      plugin_to_use.load!(options)
      loaded_plugins << plugin_to_use

      true
    end

    private

    # @return [Pathname]
    def find_project_root
      if rails?
        ::Rails.root
      else
        root_by_git || root_by_lib_dir
      end
    end

    # @return [Pathname, nil]
    def root_by_git
      _stdin, stdout, _stderr = Open3.popen3('git rev-parse --show-toplevel')
      result = stdout.gets

      result.nil? ? nil : Pathname.new(result.strip)
    end

    # @return [Pathname, nil]
    def root_by_lib_dir
      cwd = Pathname.new(Dir.pwd)
      root = nil

      cwd.ascend do |dir|
        lib_dir = File.join(dir.to_s, 'lib')

        child = dir.children.find do |c|
          c.to_s =~ /#{lib_dir}/ && File.exist?(lib_dir)
        end

        if child
          root = Pathname.new(dir.to_s)
          break
        end
      end

      root
    end
  end
end
