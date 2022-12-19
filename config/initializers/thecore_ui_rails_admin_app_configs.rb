Rails.application.configure do
    # Login Page and pages not in RailsAdmin
    config.assets.precompile += %w( thecore_ui_rails_admin/thecore.css thecore_ui_rails_admin/thecore.js )
    # Pages under Rails Admin
    config.assets.precompile += %w( thecore_ui_rails_admin/thecore_rails_admin.css thecore_ui_rails_admin/thecore_rails_admin.js )
    
    config.after_initialize do
        RailsAdmin::Config::Actions::Export.send(:include, ExportConcern)
        RailsAdmin::Config::Actions::BulkDelete.send(:include, BulkDeleteConcern)
        ThecoreSettings::Setting.send(:include, ThecoreSettings::RailsAdminExtensionConfig)
        User.send(:include, ThecoreUiRailsAdminUser)
        UsedToken.send(:include, ThecoreUiRailsAdminUsedToken) rescue puts "No UsedToken Model it could be normal: maybe model_driven_api is not installed"
        Role.send(:include, ThecoreUiRailsAdminRole)
        Permission.send(:include, ThecoreUiRailsAdminPermission)
    end
end
