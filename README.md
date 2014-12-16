hairballs
=========

Aka, "haIRBalls".  Like [oh-my-zsh](http://ohmyz.sh), but for IRB.

wat
---

haIRBalls is a framework for managing your IRB configuration.

Installation
------------

Install it yourself as:

    $ gem install hairballs

You probably don't need to add this to any Gemfile of any sort since Hairballs
and all plugin-required gems will work just fine along-side Bundler.

Usage
-----

Hairballs provides you with methods and such for creating "themes" and "plugins"
that you add in to your IRB sessions.

### Themes ###

Initially *themes* are for defining an IRB prompt using a cleaner API than the
one provide by IRB.  They are a) reusable and b) can be switched on the fly,
without requiring a reload of IRB.  Hairballs also provides methods for dealing
with dependencies and getting those dependencies to play nice with Bundler.

**Example: A Rails Theme**

This:

```ruby
# ~/.irbrc

# Specify dependencies.
libraries = %w[irb/completion awesome_print wirble looksee]

libraries += case RUBY_PLATFORM
  when /mswin32|mingw32/
    %w[win32console]
  when /darwin/
    %w[terminal-notifier]
  else
    []

# Only setup prompt if Rails.
if ENV['RAILS_ENV'] || defined? Rails
  # Allow non-Gemfile deps to work with Rails.
  if defined?(::Bundler)
    all_global_gem_paths = Dir.glob("#{Gem.dir}/gems/*")

    all_global_gem_paths.each do |p|
      gem_path = "#{p}/lib"
      $:.unshift(gem_path)
    end
  end

  # Setup the prompt.
  rails_root = File.basename(Dir.pwd)

  IRB.conf[:PROMPT][:RAILS] = {
    AUTO_INDENT: true,
    PROMPT_I: "#{rails_root}> ",
    PROMPT_S: "#{rails_root}❊%l> ",
    PROMPT_C: "#{rails_root}⇥ %i> ",
    PROMPT_N: "#{rails_root}⇥ %i> ",
    RETURN:   "➥ %s\n"
  }
  IRB.conf[:PROMPT_MODE] = :RAILS
end

# Require/install dependencies.
libraries.each do |lib|
  retry_count = 0

  begin
    break if retry_count == 2
    puts "Requiring library: #{lib}"
    require lib
  rescue LoadError
    puts "#{lib} not installed; installing now..."
    Gem.install lib
    retry_count += 1
    retry
  end
end
```

...becomes this:

```ruby
# hairballs/themes/turboladen_rails.rb
Hairballs.add_theme(:turboladen_rails) do |theme|
  theme.libraries do
    libs_to_require = %w(irb/completion looksee wirble awesome_print)

    libs_to_require +
      case RUBY_PLATFORM
      when /mswin32|mingw32/
        %w(win32console)
      when /darwin/
        %w(terminal-notifier)
      else
        []
      end
  end

  theme.extend_bundler = true

  theme.prompt do |prompt|
    preface = Hairballs.project_name

    prompt.auto_indent          = true
    prompt.normal               = "#{preface}> "
    prompt.continued_string     = "#{preface}❊%l> "
    prompt.continued_statement  = "#{preface}⇥ %i> "
    prompt.indented_code        = "#{preface}⇥ %i> "
    prompt.return_format        = "➥ %s\n"
  end
end

# ~/.irbrc
require 'hairballs/themes/turboladen_rails'

if Hairballs.rails?
  Hairballs.use_theme(:turboladen_rails)
end
```

In the end, your .irbrc is cleaned up and the theme used there can be reused and
maintained separately.  Check out the `Hairballs::Theme` docs and existing
themes under lib/hairballs/themes/ for more details and ideas.

### Plugins ###

*Plugins* are similar to *themes* in that they let you abstract away some code
from your .irbrc, thus making it cleaner and more maintainable.  The essence of
plugins, however, is to allow you to change the behavior of or add behavior to
IRB; this could mean things like:

* Installing and configuring dependencies for IRB use.
* Adding helper methods to your IRB session.
* Adding methods to certain objects, say, for debugging.
* Changing how certain objects are displayed when returned from methods.

**Example: Wirble**

Wirble has been around for years and I still like it for colorizing returned
objects in IRB.  Using a Hairballs plugin for wrapping this a) ensures wirble
is installed any time I want to use it, and b) runs the initializing of wirble
but keeps the code for doing so outside of my .irbrc.

```ruby
# hairballs/plugins/wirble.rb
Hairballs.add_plugin(:wirble) do |plugin|
  plugin.libraries %w(wirble)

  plugin.when_used do
    Wirble.init
    Wirble.colorize
  end
end

# ~/.irbrc
require 'hairballs/plugins/wirble'

Hairballs.load_plugin(:wirble)
```

Check out the Hairballs::Plugin docs and existing plugins under
lib/hairballs/plugins/ for more details and ideas.

I've got my `.irbrc` (using Hairballs) stored on the interwebs
[here](https://github.com/turboladen/config_files/blob/master/.irbrc) if
that's of any help or interest.

But whyyyy?
--------

There's some similar tools out there, but they seemed overly complicated.  IRB
is a tool for doing development and those, in my opinion, should be as simple
and straightforward as possible.

**tl:dr**

I wanted to...

* abstract away some of IRB's weirdness.
* manage IRB dependencies based on my preferences.
* for Bundler apps, use gems in IRB without having to add them to your Gemfile.
* keep `.irbrc` clean.  Make helpers reusable.

**Moar explain.**

Some problems I faced:

* Rails console loads ~/.irbrc.  If you have gem dependencies in there, you
  have to add them to your Gemfile to add them to the bundle.
    * This doesn't make sense to me.  You shouldn't make the others that are
      developing that app with you use gems for *your* IRB configuration.
    * *Solution:* `Hairballs::LibraryHelpers#libraries` and
      `Hairballs::LibraryHelpers#require_libraries`, which are available to *Themes*
      and *Plugins*.
* I want different prompt styles for regular ol' IRB vs Rails console.
    * *Solution:* `Hairballs::Theme`s.
* Customizing my prompt(s) felt so clunky!
    * *Solution:* `Hairballs::Theme`s.
* Installing and using new Rubies then running IRB meant I had to exit out and
  manually install them all.
    * zzzzzzzz...
    * *Solution:* `Hairballs::LibraryHelpers#libraries` and
      `Hairballs::LibraryHelpers#require_libraries`.
* I kept having problems with IRB and history getting all out of order--usually
  with Rails.  I was using `'irb/history'`, but trying to figure out what was
  wrong was difficult since my .irbrc had become a sprawling mass of one-off
  methods and blocks.
    * *Solution:* `hairballs/plugins/irb_history`.  This sets up IRB to use its
      `*HISTORY*` settings properly and cleanly.
* Specifying gems as IRB dependencies for different Ruby interpreters is simple
  but can clutter up your .irbrc.
    * Putting the deps with the plugin or theme that needs them keeps everything
      together and out of the .irbrc.
    * *Solution:* *Themes* and *Plugins* let you specify only the gems you need
      for those items.  Logic surrounding that (ex. platform-specific) is kept
      out of your .irbrc.

Contributing
------------

Your themes and plugins are welcome!

1. Fork it ( https://github.com/turboladen/hairballs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
