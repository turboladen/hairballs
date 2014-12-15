require_relative 'helpers'
require_relative 'prompt'

class Hairballs
  # Themes primarily provide a means for customizing the look of your IRB
  # prompt, although you're at liberty to also do any other Ruby stuff you'd
  # like, including load up common Hairballs::Plugins.
  #
  # Unless you know you do, you probably don't need to use this directly;
  # +Hairballs.add_theme()+ and +Hairballs.use_theme()+ should cover most use
  # cases.
  class Theme
    include Hairballs::Helpers

    # Just an identifier for the Theme.  Don't name two themes the same
    # name--that will cause problems.
    #
    # @param [Symbol]
    attr_accessor :name

    # Tells Hairballs to do some hackery to let Themes use gems that aren't
    # specified in your app's Gemfile.  This alleviates you from having to
    # declare gems in your Gemfile simply for the sake of managing your personal
    # IRB preferences.
    #
    # @param [Boolean]
    attr_accessor :extend_bundler

    # @param name [Symbol]
    def initialize(name)
      @name = name
      @prompt = Prompt.new
      @extend_bundler = false
    end

    # Tell IRB to use this Theme.
    def use!
      do_bundler_extending if @extend_bundler
      require_libraries
      set_up_prompt
    end

    # The name of the Theme, but in the format that IRB.conf[:PROMPT] likes (an
    # all-caps Symbol).
    #
    # @return [Symbol]
    def irb_name
      @name.to_s.upcase.to_sym
    end

    # @return [Hairballs::Prompt]
    def prompt(&block)
      if block_given?
        @prompt_block = block
      else
        @prompt
      end
    end

    #---------------------------------------------------------------------------
    # PRIVATES
    #---------------------------------------------------------------------------

    private

    # Does all the things that are required for getting IRB to use your Theme.
    def set_up_prompt
      @prompt_block.call(@prompt)
      IRB.conf[:PROMPT][irb_name] = @prompt.irb_configuration
      IRB.conf[:PROMPT_MODE] = irb_name
      IRB.CurrentContext.prompt_mode = irb_name if IRB.CurrentContext
    end

    # Add all gems in the global gemset to the $LOAD_PATH so they can be used
    # even in places like 'rails console'.
    def do_bundler_extending
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $LOAD_PATH.unshift(gem_path)
        end
      else
        vputs 'Bundler not defined.  Skipping.'
      end
    end

    # Undo the stuff that was done in #do_bundler_extending.
    def undo_bundler_extending
      if defined?(::Bundler)
        all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

        all_global_gem_paths.each do |p|
          gem_path = "#{p}/lib"
          $LOAD_PATH.delete(gem_path)
        end
      else
        vputs 'Bundler not defined.  Skipping.'
      end
    end
  end
end
