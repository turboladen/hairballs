require 'hairballs'

Hairballs.add_theme(:turboladen) do |theme|
  IRB.conf[:AUTO_INDENT] = true

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

  theme.prompt do |prompt|
    status = '  '.freeze

    preface = proc do
      if Hairballs.project_name
        "⟪#{Hairballs.project_name.light_blue}⟫#{status}%03n"
      else
        "❨#{'irb'.light_blue}❩#{status}%03n"
      end
    end

    prompt.normal = "#{preface.call}:%i> "
    prompt.continued_string = "#{preface.call('❊%l'.yellow)}:%i> "
    prompt.continued_statement = "#{preface.call('❊?'.yellow)}:%i> "
    prompt.indented_code = "#{preface.call('✚ '.yellow)}:%i> "
    prompt.return_format = "➥ %s\n".freeze
  end
end
