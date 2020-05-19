require 'active_support/concern'

module ThecoreUiRailsAdminPermission
    extend ActiveSupport::Concern
    
    included do
        
        rails_admin do
            field :predicate
            field :action
            field :target
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
            end
            edit do
                field :lock_version, :hidden do
                    visible true
                end
            end
        end
    end
end