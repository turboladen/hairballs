require 'hairballs'

Hairballs.add_theme(:turboladen_rails) do |theme|
  theme.libraries do |libs_to_require|
    libs_to_require += %w(
      awesome_print
      irb/completion
      looksee
      colorize
    )

    libs_to_require +=
      case RUBY_PLATFORM
      when /mswin32|mingw32/ then %w(win32console)
      when /darwin/ then %w(terminal-notifier)
      else []
      end

    libs_to_require
  end

  theme.extend_bundler = true

  theme.prompt do |prompt|
    preface = Hairballs.project_name.light_blue.freeze
    prompt.normal = "#{preface}> ".freeze
    prompt.continued_string = "#{preface}#{'❊%l'.yellow}> "
    prompt.continued_statement = "#{preface}#{'⇥'.yellow} %i> "
    prompt.indented_code = "#{preface}#{'⇥'.yellow} %i> "
    prompt.return_format = "➥ %s\n".freeze
  end
end
