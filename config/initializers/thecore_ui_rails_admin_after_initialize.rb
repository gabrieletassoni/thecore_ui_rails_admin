Rails.application.configure do
    config.after_initialize do
        RailsAdmin::Config::Actions.add_action "active_job_monitor", :base, :root do
            show_in_sidebar true
            show_in_navigation false
        end
        # include the extension
        RailsAdmin::Config::Actions::Export.send(:include, ExportConcern)
        RailsAdmin::Config::Actions::BulkDelete.send(:include, BulkDeleteConcern)
        Role.send :include, ThecoreUiRailsAdminRoleConcern
        UsedToken.send :include, ThecoreUiRailsAdminInvisiblesConcern rescue puts "No UsedToken Model it could be normal: maybe model_driven_api is not installed"
        User.send :include, ThecoreUiRailsAdminUserConcern
        ThecoreSettings::Setting.send :include, ThecoreUiRailsAdminSettingsConcern

        RoleUser.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Predicate.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Target.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Action.send :include, ThecoreUiRailsAdminInvisiblesConcern
        PermissionRole.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Permission.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActionText::EncryptedRichText.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActionText::RichText.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActiveStorage::Blob.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActiveStorage::Attachment.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActiveStorage::VariantRecord.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActionMailbox::InboundEmail.send :include, ThecoreUiRailsAdminInvisiblesConcern
    end
end