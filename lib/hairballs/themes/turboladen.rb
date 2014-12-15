require_relative '../../hairballs'

Hairballs.add_theme(:turboladen) do |theme|
  theme.libraries do
    libs_to_require = %w[
      irb/completion
      irb/ext/save-history
      rdoc
      awesome_print
      wirble
      looksee
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
    preface = proc do |status='  '|
      "⟪#{theme.project_name}⟫#{status}%03n"
    end

    prompt.auto_indent = true
    prompt.i = "#{preface.call}:%i> "
    prompt.s = "#{preface.call('❊%l')}:%i> "
    prompt.c = "#{preface.call('❊?')}:%i> "
    prompt.n = "#{preface.call('✚ ')}:%i> "
    prompt.return = "➥ %s\n"
  end
end
