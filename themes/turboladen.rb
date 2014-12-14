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

  theme.auto_indent = true

  define_method(:ruby_preface) do |status=' '|
    #"【#{project_name} 】#{status} %03n:"
    #"❪#{project_name} ❫#{status} %03n:"
    #"❲#{project_name} ❳#{status} %03n:"
    #"❨#{project_name} ❩#{status} %03n:"
    #"⟨#{project_name}⟩#{status} %03n:"
    #"[#{project_name}]#{status} %03n:"
    #"⎡#{project_name}⎦#{status} %03n:"
    "⟪#{theme.project_name}⟫#{status} %03n:"
  end

  theme.prompt_i = "#{ruby_preface}%i> "
  theme.prompt_s = "#{ruby_preface}%i%l "
  theme.prompt_c = "#{ruby_preface('❊')}%i> "
  theme.prompt_n = "#{ruby_preface('✚')}%i > "
  theme.return = "  ➥ %s\n"
end
