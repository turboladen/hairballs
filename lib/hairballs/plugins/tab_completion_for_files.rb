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
    files_proc = proc do |string|
      Dir['*'].grep(/^#{Regexp.escape(string)}*/)
    end

    # Hairballs.completion_proc
    completion_proc =
      if defined? ::IRB::InputCompletor::CompletionProc
        irb_proc = ::IRB::InputCompletor::CompletionProc

        Proc.new do |string|
          files = files_proc.call(string) || []
          irb_things = irb_proc.call(string) || []
          files | irb_things
        end
      else
        files_proc
      end

    if Readline.respond_to?('basic_word_break_characters=')
      Readline.basic_word_break_characters= " \"'\t\n`><=;|&{("
    end

    Readline.completion_append_character = nil
    Readline.completion_proc = completion_proc
  end
end
