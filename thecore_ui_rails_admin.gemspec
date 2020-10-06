$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "thecore_ui_rails_admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "thecore_ui_rails_admin"
  spec.version     = ThecoreUiRailsAdmin::VERSION
  spec.authors     = ["Gabriele Tassoni"]
  spec.email       = ["gabriele.tassoni@gmail.com"]
  spec.homepage    = "https://github.com/gabrieletassoni/thecore_ui_rails_admin"
  spec.summary     = "Thecore2 Backend UI based on Rails Admin."
  spec.description = "Holds all base dependencies and configurations to have a thecore integrated with Rails Admin."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "thecore_ui_commons", "~> 2.1"
  # Bootstrap 3: https://github.com/twbs/bootstrap-sass
  spec.add_dependency 'bootstrap-sass', '~> 3.4'
  # spec.add_dependency 'sassc-rails', '~> 2.0'
  # spec.add_dependency 'coffee-rails', '~> 5.0'
  # Rails Admin
  spec.add_dependency 'rails_admin_rollincode', '~> 1.3'
  spec.add_dependency 'rails_admin', '~> 2.0'
  spec.add_dependency 'rails_admin-i18n', "~> 1.12"
  spec.add_dependency 'rails_admin_toggleable', "~> 0.7"
  spec.add_dependency "safe_yaml", "~> 1.0"
  spec.add_dependency "rails_admin_selectize", "~> 2.0"
  # Rails Admin Buildups
  spec.add_dependency 'jquery-ui-rails', '~> 6.0'
end
