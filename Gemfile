# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in thecore_ui_rails_admin.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# gem 'thecore_auth_commons', path: '../thecore_auth_commons'
# gem 'thecore_backend_commons', path: '../thecore_backend_commons'
# gem 'thecore_ui_commons', path: '../thecore_ui_commons'
# gem 'rails_admin_selectize', path: '../rails_admin_selectize'

gem 'thecore_ui_commons', '~> 2.5', path: '../thecore_ui_commons'

group :development do
  gem 'rubocop'
  gem 'solargraph'
end

group :test do
  gem 'sqlite3'
end
