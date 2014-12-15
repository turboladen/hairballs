require_relative '../../hairballs'

Hairballs.add_theme(:turboladen_rails) do |theme|
  theme.libraries do
    libs_to_require = %w[
      irb/completion
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

  theme.extend_bundler = true

  theme.prompt do |prompt|
    prompt.auto_indent = true
    preface = Hairballs.project_name.light_blue
    prompt.i = "#{preface}> "
    prompt.s = "#{preface}:❊%l> "
    prompt.c = "#{preface}:⇥ %i> "
    prompt.n = "#{preface}:⇥ %i> "
    prompt.return = "➥ %s\n"
  end
end
