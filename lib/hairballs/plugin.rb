require 'hairballs/exceptions'
require 'hairballs/library_helpers'

class Hairballs
  # Plugins provide means for adding functionality to your IRB sessions.  They
  # can be as simple as requiring other gems, or as complex as you want them to
  # be.
  #
  # One benefit of making a simple plugin for requiring other deps is
  # Hairballs::LibraryHelpers#require_libraries method. When used in
  # conjunction with Hairballs::LibraryHelpers#libraries, you don't have to
  # worry about installing the gems before using IRB. This is particularly
  # helpful when using a Ruby manager (RVM, rbenv, etc) and you install a new
  # Ruby; if you don't think ahead to install your IRB deps, your IRB session
  # won't behave like you want; well, not until you `exit` and fix the problem.
  # This simple pattern helps alleviate that small headache.
  #
  # Next, Hairballs Plugins are lazily loaded; `require`ing their source files
  # doesn't mean the methods and such that you add there will do anything; it's
  # not until you `Hairballs.load_plugin(:blargh)` that the code that defines
  # your plugin will get executed.
  class Plugin
    include LibraryHelpers

    # @return [Symbol]
    attr_reader :name

    # @param name [Symbol]
    # @param attributes [Hash] These become attributes (with reader and writer
    #   methods) of the Plugin.  It's really just a mechanism for defining
    #   available attributes and their default values.
    def initialize(name, **attributes)
      @name = name
      @irb_configuration = nil

      attributes.each do |k, v|
        define_singleton_method(k) do
          instance_variable_get("@#{k}".to_sym)
        end

        define_singleton_method("#{k}=") do |new_value|
          instance_variable_set("@#{k}".to_sym, new_value)
        end

        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    # Everything in the +block+ given here will be the last code to get
    # evaluated when #load! is called.  This is where you define code that makes
    # up your plugin.
    def on_load(&block)
      @on_load = block
    end

    # Loads the plugin using the +attributes+ values.  The keys in +attributes+
    # must match attributes that were given when the Plugin was defined.
    # Attribute values given here will override the defaults that were given
    # when the Plugin was defined.
    def load!(**attributes)
      attributes.each do |k, v|
        send("#{k}=".to_sym, v)
      end

      require_libraries

      return unless @on_load

      if @on_load.kind_of?(Proc)
        @on_load.call
      else
        fail PluginLoadFailure, name
      end
    end
  end
end
