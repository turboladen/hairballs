require 'forwardable'
require 'hairballs/version'
require 'hairballs/configuration'

# Home of the Hairballs DSL for defining and using Themes and Plugins.
class Hairballs
  # @return [Hairballs::Configuration]
  def self.config
    @config ||= Hairballs::Configuration.new
  end

  class << self
    extend Forwardable

    def_delegators :config,
                   :themes,
                   :add_theme,
                   :current_theme,
                   :use_theme,

                   :plugins,
                   :load_plugin,
                   :loaded_plugins,
                   :add_plugin,

                   :completion_procs,

                   :project_name,
                   :project_root,
                   :version,
                   :rails?
  end
end
