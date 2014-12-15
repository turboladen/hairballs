require_relative '../../hairballs'

Hairballs.add_plugin(:irb_history, save_history: 1000, eval_history: 20, global_history_file: true) do |plugin|
  plugin.libraries %w[irb/ext/save-history]

  plugin.when_used do
    IRB.conf[:SAVE_HISTORY] = plugin.save_history
    IRB.conf[:EVAL_HISTORY] = plugin.eval_history

    unless plugin.global_history_file
      IRB.conf[:HISTORY_FILE] = "#{Dir.home}/.irb_history-#{Hairballs.project_name}"
    end
  end
end
