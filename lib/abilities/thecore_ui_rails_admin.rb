module Abilities
    class ThecoreUiRailsAdmin
        include CanCan::Ability
        def initialize user
            # No one is allowed to add or destroy settings
            # just list or edit existing
            cannot :create, ThecoreSettings::Setting
            cannot :destroy, ThecoreSettings::Setting
            cannot :show, ThecoreSettings::Setting
        end
    end
end
