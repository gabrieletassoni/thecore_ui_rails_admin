require 'thecore_ui_commons'
# Rails Admin
# ENV['RAILS_ADMIN_THEME'] ||= 'rollincode'
# require 'rails_admin_rollincode'
require 'rails_admin'
require 'rails_admin-i18n'
require 'safe_yaml'
require 'rails_admin_toggleable'
require 'rails_admin_selectize'
require 'concerns/rails_admin_requirements'
# Abilities
require 'abilities/thecore_ui_rails_admin'
# Rails Admin Buildups
# require 'jquery-ui-rails'
require 'bootstrap-sass'

require 'concerns/thecore_ui_rails_admin_user'
require 'concerns/thecore_ui_rails_admin_used_token'
require 'concerns/thecore_ui_rails_admin_role'
require 'concerns/thecore_ui_rails_admin_permission'
require 'concerns/thecore_rails_admin_export_concern'
require 'concerns/thecore_rails_admin_bulk_delete_concern'

require 'blazer'

require "thecore_ui_rails_admin/engine"

module ThecoreUiRailsAdmin
  # Rails Admin Settings
  SafeYAML::OPTIONS[:default_mode] = :safe
  SafeYAML::OPTIONS[:deserialize_symbols] = false
end

puts "Loading Root Monitor Libraries"
require 'iframes/sidekiq_monitor'
require 'iframes/blazer_bi'
