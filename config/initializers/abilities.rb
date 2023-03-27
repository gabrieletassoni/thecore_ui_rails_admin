module Abilities
    class ThecoreUiRailsAdmin
        include CanCan::Ability
        def initialize user
            # No one is allowed to add or destroy settings
            # just list or edit existing
            cannot [:create, :destroy, :show], ThecoreSettings::Setting

            cannot [:destroy, :update, :edit, :show], Action
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
