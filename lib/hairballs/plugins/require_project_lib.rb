require 'hairballs'

# Adds the Object#require_project_lib method as a shortcut for
#
#     require 'lib/my_library'          # Or...
#     require 'lib/my/nested/project'   # i.e. gem = my-nested-project
#
Hairballs.add_plugin(:require_project_lib) do |plugin|
  plugin.on_load do
    Object.class_eval do
      def require_project_lib
        require_dir = File.join(*Hairballs.project_name.to_s.split('-'))
        require_relative "#{Dir.pwd}/lib/#{require_dir}"
      end
    end
  end
end
