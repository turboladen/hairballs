require 'hairballs'

Hairballs.add_theme(:turboladen_rails) do |theme|
  theme.libraries do |libs_to_require|
    libs_to_require += %w(
      irb/completion
      looksee
      colorize
    )

    libs_to_require +=
      case RUBY_PLATFORM
      when /mswin32|mingw32/
        %w(win32console)
      when /darwin/
        %w(terminal-notifier)
      else
        []
      end

    libs_to_require
  end

  theme.extend_bundler = true

  theme.prompt do |prompt|
    prompt.auto_indent = true
    preface = Hairballs.project_name.light_blue
    prompt.normal = "#{preface}> "
    prompt.continued_string = "#{preface}#{'❊%l'.yellow}> "
    prompt.continued_statement = "#{preface}#{'⇥'.yellow} %i> "
    prompt.indented_code = "#{preface}#{'⇥'.yellow} %i> "
    prompt.return_format = "➥ %s\n"
  end
end
