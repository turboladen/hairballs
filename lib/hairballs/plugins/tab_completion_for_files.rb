require_relative '../../hairballs'

# Adds the ability to tab-complete files that are in the current directory.
#
# Example:
#
#     # If in the hairballs project root, doing this...
#     irb> File.read("READ⇥
#     # Will complete like this...
#     irb> File.read("README.md"
#
Hairballs.add_plugin(:tab_completion_for_files) do |plugin|
  plugin.on_load do
    Hairballs.completion_procs << proc do |string|
      Dir['*'].grep(/^#{Regexp.escape(string)}*/)
    end

    if defined? ::IRB::InputCompletor::CompletionProc
      Hairballs.completion_procs << ::IRB::InputCompletor::CompletionProc
    end

    completion_proc = Proc.new do |string|
      Hairballs.completion_procs.map do |proc|
        proc.call(string)
      end.flatten.uniq
    end

    if Readline.respond_to?('basic_word_break_characters=')
      Readline.basic_word_break_characters= " \"'\t\n`><=;|&{("
    end

    Readline.completion_append_character = nil
    Readline.completion_proc = completion_proc
  end
end
