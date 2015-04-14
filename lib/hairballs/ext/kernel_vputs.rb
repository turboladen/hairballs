# Adding #vputs.
module Kernel
  # Does a puts only if IRB is in verbose mode.
  def vputs(*messages)
    messages.map! { |m| "[Hairballs] #{m}" }
    puts(*messages) if defined?(::IRB) && ::IRB.conf[:VERBOSE]
  end
end
