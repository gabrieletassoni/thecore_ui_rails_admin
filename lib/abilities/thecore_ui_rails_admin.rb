module Abilities
    class ThecoreUiRailsAdmin
        include CanCan::Ability
        def initialize user
            # No one is allowed to add or destroy settings
            # just list or edit existing
            cannot :create, RailsAdminSettings::Setting
            cannot :destroy, RailsAdminSettings::Setting
            cannot :show, RailsAdminSettings::Setting
        end
    end
end
