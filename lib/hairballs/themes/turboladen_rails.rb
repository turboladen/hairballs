require_relative '../../hairballs'

Hairballs.add_theme(:turboladen_rails) do |theme|
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

  theme.extend_bundler = true

  theme.prompt do |prompt|
    prompt.auto_indent = true
    prompt.i = "#{Hairballs.project_name}> "
    prompt.s = "#{Hairballs.project_name}:❊%l> "
    prompt.c = "#{Hairballs.project_name}:⇥ %i> "
    prompt.n = "#{Hairballs.project_name}:⇥ %i> "
    prompt.return = "➥ %s\n"
  end
end
