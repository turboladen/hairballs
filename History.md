### 0.1.2 / 2015-04-13

* Improvements
    * Used Rubocop for static analysis and clean-up.
    * Started running tests on travis-ci.
* Bug Fixes
    * [#4](https://github.com/turboladen/hairballs/issues/4) Fixed installing of
      missing plugin/theme dependencies.
    * [#5](https://github.com/turboladen/hairballs/issues/5) Fixed bad use of
      `Hairballs.project_name` everywhere.
    * Fixed bad link to my .irbrc in the README.

### 0.1.1 / 2015-04-06

* Bug Fixes
    * Fixed #root_by_git when not in a git director. This would result in
      `NoMethodError: undefined method 'strip' for nil:NilClass`.
    * Plugin: *irb_history* Fixed IRB history for non-project sessions. All IRB 
      sessions that don't belong to a project are saved to `~/.irb_history`.

### 0.1.0 / 2015-02-18

* Improvements
    * Added `Hairballs.project_root`, which tries to determine the root
      directory for the project you're working in.
    * Refactored configuration to `Hairballs::Configuration`.
* Bug Fixes
    * Fixed `Hairballs::LibraryHelpers#find_latest_gem` to find the latest
      instead of the earliest.
    * Plugin: *tab_completion_for_files* Fixed nested file completion.

### 0.0.1 / 2014-12-19

* Happy Birthday!
