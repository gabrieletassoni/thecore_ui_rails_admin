Rails.application.configure do
    # config.assets.paths << root.join("app", "assets", "stylesheets", "thecore_ui_rails_admin")
    # config.assets.paths << root.join("app", "assets", "javascripts", "thecore_ui_rails_admin")
    # Login Page and pages not in RailsAdmin
    config.assets.precompile += %w( thecore_ui_rails_admin/thecore.css thecore_ui_rails_admin/thecore.js )
    # Pages under Rails Admin
    config.assets.precompile += %w( thecore_ui_rails_admin/thecore_rails_admin.css thecore_ui_rails_admin/thecore_rails_admin.js )
    
    config.after_initialize do
        RailsAdmin::Config::Actions::Export.send(:include, ExportConcern)
        RailsAdmin::Config::Actions::BulkDelete.send(:include, BulkDeleteConcern)
        RailsAdminSettings::Setting.send(:include, RailsAdminSettings::RailsAdminExtensionConfig)
        User.send(:include, ThecoreUiRailsAdminUser)
        UsedToken.send(:include, ThecoreUiRailsAdminUsedToken)
        Role.send(:include, ThecoreUiRailsAdminRole)
        Permission.send(:include, ThecoreUiRailsAdminPermission)
    end
end