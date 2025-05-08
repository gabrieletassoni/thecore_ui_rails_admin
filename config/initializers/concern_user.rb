puts "User Concern from ThecoreUiRailsAdmin"
require 'active_support/concern'

module ThecoreUiRailsAdminUserConcern
    extend ActiveSupport::Concern
    
    included do
        has_many :saved_filters, class_name: 'SavedFilter', foreign_key: :admin_user_id, dependent: :destroy

        # def admin_enum
        #     [["✔",true],['✘',false]]
        # end

        # def locked_enum
        #     [["✔",true],['✘',false]]
        # end
        # 
        
        # locale field is a string which can be chosen from the list of available locales: it and en
        # The default locale is the one set in the I18n.default_locale
        # The locale is used to set the language of the user
        def locale_enum
            [['Italiano', 'it'], ['English', 'en']]
        end
        
        rails_admin do
            navigation_label Proc.new { I18n.t("admin.settings.label") }
            navigation_icon 'fa fa-user-circle'
            parent Role
            # desc Proc.new { I18n.t("activerecord.descriptions.user") }
            
            # Hide fields: :id, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :lock_version, :role_users
            configure :id do
                hide
            end
            configure :remember_created_at do
                hide
            end
            configure :sign_in_count do
                hide
            end
            configure :current_sign_in_at do
                hide
            end
            configure :last_sign_in_at do
                hide
            end
            configure :current_sign_in_ip do
                hide
            end
            configure :last_sign_in_ip do
                hide
            end
            configure :lock_version do
                hide
            end
            configure :role_users do
                hide
            end
            configure :saved_filters do
              hide
            end

            update do
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