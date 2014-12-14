require_relative '../lib/hairballs'

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
    prompt.auto_indent = true
    prompt.preface { |status| "⟪#{theme.project_name}⟫#{status} %03n:" }
    prompt.i = "#{theme.prompt.preface}%i> "
    prompt.s = "#{theme.prompt.preface}%i%l "
    prompt.c = "#{theme.prompt.preface('❊')}%i> "
    prompt.n = "#{theme.prompt.preface('✚')}%i > "
    prompt.return = "  ➥ %s\n"
  end

  #"【#{project_name} 】#{status} %03n:"
  #"❪#{project_name} ❫#{status} %03n:"
  #"❲#{project_name} ❳#{status} %03n:"
  #"❨#{project_name} ❩#{status} %03n:"
  #"⟨#{project_name}⟩#{status} %03n:"
  #"[#{project_name}]#{status} %03n:"
  #"⎡#{project_name}⎦#{status} %03n:"
end
