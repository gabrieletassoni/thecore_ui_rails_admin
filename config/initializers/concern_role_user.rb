puts "RoleUser Concern from ThecoreUiRailsAdmin"
require 'active_support/concern'

module ThecoreUiRailsAdminRoleUserConcern
    extend ActiveSupport::Concern
    
    included do
        
        rails_admin do
            navigation_label I18n.t("admin.settings.label")
            navigation_icon 'fas fa-users'
            desc I18n.t("activerecord.descriptions.role")
            
            visible false
        end
    end
end