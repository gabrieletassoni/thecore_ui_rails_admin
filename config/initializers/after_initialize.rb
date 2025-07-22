Rails.application.configure do
    config.after_initialize do
        puts "ThecoreUiRailsAdmin after_initialize"

        RailsAdmin::ApplicationController.send(:include, ConcernCommonApplicationController)
        ApplicationController.send(:include, ConcernRAApplicationController)
        RailsAdmin::ApplicationController.send(:include, ConcernRAApplicationController)
        ## Rails Admin
        require 'rails_admin_abstract_controller'
        RailsAdmin::Config.parent_controller = '::RailsAdminAbstractController'
        ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
        ## == Devise ==
        RailsAdmin::Config.authenticate_with do 
            warden.authenticate! scope: :user 
        end
        RailsAdmin::Config.current_user_method(&:current_user)

        ## == Cancan ==
        RailsAdmin::Config.authorize_with :cancancan

        RailsAdmin::Config.main_app_name = Proc.new { |controller| [ ((ThecoreSettings::Setting.where(ns: :main, key: :app_name).pluck(:raw).first.presence || ENV["APP_NAME"]) rescue "Thecore"), "" ] }

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
        require 'member_actions/test_ldap_server'
        require 'member_actions/import_users_from_ldap'
        require 'collection_actions/save_filters'
        require 'collection_actions/load_filters'
    end
end