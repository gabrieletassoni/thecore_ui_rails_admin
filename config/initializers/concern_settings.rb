puts "Settings Concern from ThecoreUiRailsAdmin"
require 'active_support/concern'

module ThecoreUiRailsAdminSettingsConcern
  extend ActiveSupport::Concern
  included do
    rails_admin do
      navigation_icon 'fa fa-cogs'
    end

    def display_name
      "#{I18n.t "settings.namespaces.#{ns}", default: ns.titleize}: #{I18n.t "settings.names.#{name}", default: name.titleize}"
    end
  end
end
