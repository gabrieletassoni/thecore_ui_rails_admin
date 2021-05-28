require 'active_support/concern'

module ThecoreUiRailsAdminUsedToken
    extend ActiveSupport::Concern
    
    included do
        rails_admin do
            visible false
        end
    end
end