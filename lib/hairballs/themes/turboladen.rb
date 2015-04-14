require 'hairballs'

Hairballs.add_theme(:turboladen) do |theme|
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

  theme.prompt do |prompt|
    preface = proc do |status = '  '|
      if Hairballs.project_name
        "⟪#{Hairballs.project_name.to_s.light_blue}⟫#{status}%03n"
      else
        "❨#{'irb'.light_blue}❩#{status}%03n"
      end
    end

    prompt.auto_indent = true
    prompt.normal = "#{preface.call}:%i> "
    prompt.continued_string = "#{preface.call('❊%l'.yellow)}:%i> "
    prompt.continued_statement = "#{preface.call('❊?'.yellow)}:%i> "
    prompt.indented_code = "#{preface.call('✚ '.yellow)}:%i> "
    prompt.return_format = "➥ %s\n"
  end
end
