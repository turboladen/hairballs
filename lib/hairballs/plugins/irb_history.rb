require 'hairballs'

Hairballs.add_plugin(:irb_history, save_history: 1000, eval_history: 20, global_history_file: true) do |plugin|
  plugin.libraries %w(irb/ext/save-history)

  plugin.on_load do
    IRB.conf[:SAVE_HISTORY] = plugin.save_history
    IRB.conf[:EVAL_HISTORY] = plugin.eval_history

    unless plugin.global_history_file && Hairballs.project_name
      IRB.conf[:HISTORY_FILE] = "#{Dir.home}/.irb_history"

      if Hairballs.project_name
        IRB.conf[:HISTORY_FILE] << Hairballs.project_name.to_s
      end
    end

    Object.class_eval do
      # All of the ruby lines of code that have been executed.
      def history
        0.upto(Readline::HISTORY.size - 1) do |i|
          printf "%5d %s\n", i, Readline::HISTORY[i]
        end
      end

      # Execute one or many lines of Ruby from +history+.
      #
      # @param command_numbers [Fixnum,Range]
      def _!(command_numbers)
        cmds =
          if command_numbers.is_a? Range
            command_numbers.to_a.map { |i| Readline::HISTORY[i] }
          else
            [Readline::HISTORY[command_numbers]]
          end

        cmds.each { |cmd| send(cmd) }
      end
    end
  end
end
