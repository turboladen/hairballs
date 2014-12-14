require_relative 'hairballs/version'
require_relative 'hairballs/theme'


class Hairballs
  def self.themes
    @themes ||= []
  end

  def self.add_theme(name)
    theme = Theme.new(name)
    yield theme
    themes << theme

    theme
  end

  def self.use_theme(theme_name)
    switch_to = themes.find { |theme| theme.name == theme_name }
    fail 'meow' unless switch_to
    puts "found theme: #{switch_to.name}"

    switch_to.use!
  end
end
