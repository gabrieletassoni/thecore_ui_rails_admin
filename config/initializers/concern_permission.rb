puts "Permission Concern from ThecoreUiRailsAdmin"
require 'active_support/concern'

module ThecoreUiRailsAdminPermissionConcern
    extend ActiveSupport::Concern
    
    included do
        
        rails_admin do
            navigation_label I18n.t("admin.settings.label")
            navigation_icon 'fas fa-users'
            desc I18n.t("activerecord.descriptions.role")
            
            visible false

            exclude_fields :id, :lock_version, :updated_at, :permission_roles, :roles
        end
    end
end