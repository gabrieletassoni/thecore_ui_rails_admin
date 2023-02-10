module Abilities
    class ThecoreUiRailsAdmin
        include CanCan::Ability
        def initialize user
            # No one is allowed to add or destroy settings
            # just list or edit existing
            cannot :create, ThecoreSettings::Setting
            cannot :destroy, ThecoreSettings::Setting
            cannot :show, ThecoreSettings::Setting
            # Main abilities file for Thecore applications
            if user.present?
                # Users' abilities
                if user.admin?
                    # Admins' abilities
                end
            end
        end
    end
end
