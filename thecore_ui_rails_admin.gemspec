$:.push File.expand_path("lib", __dir__)

require_relative "lib/thecore_ui_rails_admin/version"

Gem::Specification.new do |spec|
  spec.name        = "thecore_ui_rails_admin"
  spec.version     = ThecoreUiRailsAdmin::VERSION
  spec.authors     = ["Gabriele Tassoni"]
  spec.email       = ["g.tassoni@bancolini.com"]
  spec.homepage    = "https://github.com/gabrieletassoni/thecore_ui_rails_admin"
  spec.summary     = "Thecore Backend UI based on Rails Admin."
  spec.description = "Holds all base dependencies and configurations to have a thecore integrated with Rails Admin."
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gabrieletassoni/thecore_ui_rails_admin"
  spec.metadata["changelog_uri"] = "https://github.com/gabrieletassoni/thecore_ui_rails_admin/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "thecore_ui_commons", "~> 3.1"
  spec.add_dependency "rails_admin", "~> 3.1"
  spec.add_dependency "rails_admin-i18n", "~> 1.18"
  # spec.add_dependency "rails_admin_toggleable", "~> 0.8"
  # https://github.com/stephskardal/rails_admin_import
  # spec.add_dependency "rails_admin_import", "~> 3.0"
  # https://github.com/dalpo/rails_admin_clone
  # spec.add_dependency "rails_admin_clone", "~> 0.0"
end
