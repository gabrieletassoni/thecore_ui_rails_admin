require 'active_support/concern'

module ThecoreUiRailsAdminInvisiblesConcern
    extend ActiveSupport::Concern
    
    included do
        rails_admin do
            visible false
        end
    end
end
