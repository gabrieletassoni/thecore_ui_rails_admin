require 'thecore_ui_commons'
# Rails Admin
ENV['RAILS_ADMIN_THEME'] ||= 'rollincode'
require 'rails_admin_rollincode'
require 'rails_admin'
require 'rails_admin-i18n'
require 'rails_admin_toggleable'
# Rails Admin Buildups
require 'jquery-ui-rails'
require 'bootstrap-sass'

require 'concerns/thecore_ui_rails_admin_user'

require "thecore_ui_rails_admin/engine"

module ThecoreUiRailsAdmin
  # Your code goes here...
end
