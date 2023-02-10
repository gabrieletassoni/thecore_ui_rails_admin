require 'active_support/concern'

module ThecoreUiRailsAdminUserConcern
    extend ActiveSupport::Concern
    
    included do
        
        rails_admin do
            # rails_admin do
            navigation_label I18n.t("admin.settings.label")
            navigation_icon 'fa fa-user-circle'
            parent Role
            desc I18n.t("activerecord.descriptions.user")
            
            # Field present Everywhere
            field :email do
                required true
            end
            field :admin do
                visible do
                    bindings[:view].current_user.admin? && bindings[:view].current_user.id != bindings[:object].id rescue false
                end
            end
            field :locked do
                visible do
                    bindings[:view].current_user.admin? && bindings[:view].current_user.id != bindings[:object].id rescue false
                end
            end
            field :roles#, :selectize
            
            # Fields only in lists and forms
            list do
                field :created_at
                exclude_fields :lock_version
                # include UserRailsAdminListConcern
            end
            show do
                #exclude_fields :id
                exclude_fields :lock_version
            end
            create do
                field :password do
                    required true
                end
                field :password_confirmation do
                    required true
                end
                # field :lock_version, :hidden do
                #     visible true
                # end
                # include UserRailsAdminCreateConcern
            end
            edit do
                field :password do
                    required false
                end
                field :password_confirmation do
                    required false
                end
                
                # field :lock_version, :hidden do
                #     visible true
                # end
                # include UserRailsAdminEditConcern
                
            end
        end
    end
end