require 'active_support/concern'

module ThecoreUiRailsAdminRoleConcern
    extend ActiveSupport::Concern
    
    included do
        
        rails_admin do
            navigation_label I18n.t("admin.settings.label")
            navigation_icon 'fas fa-users'
            desc I18n.t("activerecord.descriptions.role")
            
            field :name
            field :permissions#, :selectize

            list do
                field :created_at
                field :updated_at
            end
            show do
                exclude_fields :id
            end
        end
    end
end