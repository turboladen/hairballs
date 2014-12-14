require_relative '../theme'

class Hairballs
  module Themes
    module TurboladenRails
      include Hairballs::Theme

      require_libraries do
        libs_to_require = %w[
          irb/completion
          irb/ext/save-history
          rdoc
          awesome_print
          wirble
          looksee
        ]

        libs_to_require +=
          case RUBY_PLATFORM
          when /mswin32|mingw32/
            %w[win32console]
          when /darwin/
            %w[terminal-notifier]
          else
            []
          end
      end
    end
  end
end
