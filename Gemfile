source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in thecore_ui_rails_admin.gemspec.
gemspec

gem "sqlite3"

# TEMPORARY: thecore_backend_commons's ThecoreBackendCommons::DefaultModuleRegistry
# (gabrieletassoni/thecore_backend_commons PR #4) is merged into its release/3
# branch but not yet cut into a RubyGems release satisfying the gemspec's
# ">= 3.4" constraint. Pin to the release/3 branch (contains merge commit
# 776a92a, version 3.4.1) until a real thecore_backend_commons release ships;
# remove this override afterwards and let the gemspec constraint resolve
# normally from RubyGems.
gem "thecore_backend_commons", github: "gabrieletassoni/thecore_backend_commons", branch: "release/3"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
