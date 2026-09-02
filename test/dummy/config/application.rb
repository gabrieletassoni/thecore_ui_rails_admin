require_relative "boot"

require "rails/all"

# Stub config.assets -- sprockets/propshaft is not in this gem's bundle, but
# thecore_backend_commons's config/initializers/application_config.rb (now a
# real transitive dependency, see Gemfile) unconditionally sets
# `config.assets.prefix` at boot. Mirrors the identical stub in
# thecore_backend_commons's own test/dummy/config/application.rb.
stub_class = Class.new do
  def method_missing(name, *args, &block)
    name_s = name.to_s
    return false if name_s.end_with?("?")
    return nil   if name_s.end_with?("=") || args.any? || block
    ivar = :"@_s_#{name_s.gsub(/\W/, "_")}"
    instance_variable_get(ivar) || instance_variable_set(ivar, self.class.new)
  end
  def respond_to_missing?(name, *) = name.to_s != "to_ary"
end

Rails::Application::Configuration.prepend(Module.new do
  define_method(:assets) { @_stub_assets ||= stub_class.new }
end)

# Stub ModelDrivenApi.smart_merge -- model_driven_api is not in this gem's
# bundle. thecore_backend_commons's BaseApplicationRecordConcern calls
# ::ModelDrivenApi.smart_merge in its `included do` block, and (via its own
# legacy `ApplicationRecord.subclasses.each { |d| d.include(...) }` scan in
# config.after_initialize, not the new DefaultModuleRegistry) may reach
# real engine models (User, Role, ...) autoloaded during this dummy app's
# boot -- particularly under eager loading (CI=true, see test.rb).
module ModelDrivenApi
  def self.smart_merge(base, additions)
    base.merge(additions) { |_, a, b| a.is_a?(Array) && b.is_a?(Array) ? (a + b).uniq : b }
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "thecore_ui_rails_admin"

# thecore_auth_commons's own config/initializers/after_initialize.rb does
# `Ability.send(:include, ThecoreAuthCommonsCanCanCanConcern)` -- it expects
# the *host app* to already define `Ability` (it deliberately does not
# define one itself). thecore_backend_commons's own
# config/initializers/after_initialize.rb similarly expects `User` and
# `ApplicationCable::Connection` to exist, and thecore_ui_commons's
# config/routes.rb draws `devise_for :users` against `User`. Preloading
# these dummy classes makes them available in time (mirrors the same
# preload thecore_backend_commons's own test/dummy/config/application.rb
# does for its own dummy app) -- `User` here intentionally shadows
# thecore_auth_commons's own `app/models/user.rb` (a supported/documented
# Rails engine override: the main application's own file at the same
# relative autoload path wins over an engine's).
#
# `User` specifically must be required from inside an
# `ActiveSupport.on_load(:active_record)` callback, registered here (i.e.
# *after* Bundler.require has already loaded Devise, which registers its
# own `:active_record` callback that extends `Devise::Models` on to
# ActiveRecord::Base) rather than eagerly up front: `on_load` callbacks run
# in registration order once the load event actually fires, so this
# guarantees Devise's `devise` class method exists on ActiveRecord::Base by
# the time `User`'s class body calls it. `Ability`/`ApplicationCable::Connection`
# have no such ordering constraint (they don't touch ActiveRecord).
require File.expand_path("../app/models/ability", __dir__)
require File.expand_path("../app/channels/application_cable/connection", __dir__)
ActiveSupport.on_load(:active_record) do
  # Deterministically force Devise's ActiveRecord ORM adapter (which itself
  # just does `ActiveSupport.on_load(:active_record) { extend Devise::Models }`)
  # regardless of whether Bundler happened to load `devise` before or after
  # ActiveRecord::Base first fired this same load hook -- `on_load` runs its
  # block immediately, synchronously, when the hook has already fired once
  # (as it has here), so this guarantees `ActiveRecord::Base.devise` exists
  # before `User`'s class body below calls it.
  require "devise/orm/active_record"

  require File.expand_path("../app/models/application_record", __dir__)
  require File.expand_path("../app/models/user", __dir__)
end

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
