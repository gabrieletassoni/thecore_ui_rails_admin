source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in thecore_ui_rails_admin.gemspec.
gemspec

# json 3.0+ turns the long-tolerated, deprecated `quirks_mode:` option into a hard ArgumentError;
# activesupport (Rails 7.2's JSON encoder) still passes it on every JSON.generate call, so any
# request that commits a session cookie crashes. Same fix as the host app's own Gemfile — pin
# until Rails 8 ships a compatible activesupport release.
gem 'json', '< 3.0'

gem "sqlite3"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
