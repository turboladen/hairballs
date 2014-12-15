require_relative '../../hairballs'

Hairballs.add_theme(:turboladen) do |theme|
  theme.libraries do
    libs_to_require = %w[
      irb/completion
      looksee
      colorize
    ]

    libs_to_require += case RUBY_PLATFORM
      when /mswin32|mingw32/
        %w[win32console]
      when /darwin/
        %w[terminal-notifier]
      else
        []
      end
  end

  theme.prompt do |prompt|
    require 'colorize'

    preface = proc do |status='  '|
      "⟪#{theme.project_name.light_blue}⟫#{status}%03n"
    end

    prompt.auto_indent = true
    prompt.i = "#{preface.call}:%i> "
    prompt.s = "#{preface.call('❊%l'.yellow)}:%i> "
    prompt.c = "#{preface.call('❊?'.yellow)}:%i> "
    prompt.n = "#{preface.call('✚ '.yellow)}:%i> "
    prompt.return = "➥ %s\n"
  end
end
