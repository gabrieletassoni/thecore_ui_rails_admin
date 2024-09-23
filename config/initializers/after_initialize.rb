Rails.application.configure do
    config.after_initialize do
        puts "ThecoreUiRailsAdmin after_initialize"

        RailsAdmin::ApplicationController.send(:include, ConcernCommonApplicationController)
        ApplicationController.send(:include, ConcernRAApplicationController)
        RailsAdmin::ApplicationController.send(:include, ConcernRAApplicationController)
        ## Rails Admin
        ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
        ## == Devise ==
        RailsAdmin::Config.authenticate_with do 
            warden.authenticate! scope: :user 
        end
        RailsAdmin::Config.current_user_method(&:current_user)

        ## == Cancan ==
        RailsAdmin::Config.authorize_with :cancancan

        # RailsAdmin::Config.sidescroll = { num_frozen_columns: 2 }

        RailsAdmin::Config.main_app_name = Proc.new { |controller| [ ((ENV["APP_NAME"].presence || Settings.app_name.presence) rescue "Thecore"), "" ] }

        RailsAdmin::Config.show_gravatar = false

        RailsAdmin::Config.label_methods.unshift(:display_name)

        RailsAdmin::Config.excluded_models << ActionText::RichText
        RailsAdmin::Config.excluded_models << ActionText::EncryptedRichText
        RailsAdmin::Config.excluded_models << ActiveStorage::Blob
        RailsAdmin::Config.excluded_models << ActiveStorage::Attachment
        RailsAdmin::Config.excluded_models << ActiveStorage::VariantRecord
        RailsAdmin::Config.excluded_models << ActionMailbox::InboundEmail
        RailsAdmin::Config.excluded_models << UsedToken rescue puts "No UsedToken Model it could be normal: maybe model_driven_api is not installed"

        RailsAdmin::Config::Actions::Export.send(:include, ExportConcern)
        RailsAdmin::Config::Actions::BulkDelete.send(:include, BulkDeleteConcern)

        Role.send :include, ThecoreUiRailsAdminRoleConcern
        User.send :include, ThecoreUiRailsAdminUserConcern
        RoleUser.send :include, ThecoreUiRailsAdminRoleUserConcern
        Action.send :include, ThecoreUiRailsAdminActionConcern
        PermissionRole.send :include, ThecoreUiRailsAdminPermissionRoleConcern
        Permission.send :include, ThecoreUiRailsAdminPermissionConcern
        Predicate.send :include, ThecoreUiRailsAdminPredicateConcern
        Target.send :include, ThecoreUiRailsAdminTargetConcern
        ThecoreSettings::Setting.send :include, ThecoreUiRailsAdminSettingsConcern

        require 'root_actions/active_job_monitor'
        require 'member_actions/change_password'
    end
end