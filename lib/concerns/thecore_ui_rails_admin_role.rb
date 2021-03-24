require 'active_support/concern'

module ThecoreUiRailsAdminRole
    extend ActiveSupport::Concern
    
    included do
        
        rails_admin do
            navigation_label I18n.t("admin.settings.label")
            navigation_icon 'fa fa-group'
            desc I18n.t("activerecord.descriptions.role")
            
            field :name
            field :permissions#, :selectize
            list do
                field :created_at
                exclude_fields :lock_version
            end
            show do
                exclude_fields :id
                exclude_fields :lock_version
            end
            create do
                field :lock_version, :hidden do
                    visible true
                end
                # include UserRailsAdminCreateConcern
            end
            edit do
                field :lock_version, :hidden do
                    visible true
                end
            end
        end
    end
end