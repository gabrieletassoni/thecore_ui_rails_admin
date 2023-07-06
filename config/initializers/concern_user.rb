puts "User Concern from ThecoreUiRailsAdmin"
require 'active_support/concern'

module ThecoreUiRailsAdminUserConcern
    extend ActiveSupport::Concern
    
    included do

        # def admin_enum
        #     [["✔",true],['✘',false]]
        # end

        # def locked_enum
        #     [["✔",true],['✘',false]]
        # end
        
        rails_admin do
            navigation_label I18n.t("admin.settings.label")
            navigation_icon 'fa fa-user-circle'
            parent Role
            desc I18n.t("activerecord.descriptions.user")
            
            exclude_fields :id, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :lock_version, :role_users

            edit do
                configure :password do
                    hide
                end
                configure :password_confirmation do
                    hide
                end
            end

            create do
                configure :password do
                    required true
                end
                configure :password_confirmation do
                    required true
                end
            end
        end
    end
end