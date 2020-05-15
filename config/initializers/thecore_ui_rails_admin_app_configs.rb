Rails.application.configure do
    
    config.assets.precompile += %w( thecore_rails_admin.css )

    puts "ASSETS PRECOMPILE: #{config.assets.precompile.inspect}"

    config.after_initialize do
        RailsAdmin::Config::Actions::Export.send(:include, ExportConcern)
        RailsAdmin::Config::Actions::BulkDelete.send(:include, BulkDeleteConcern)
        User.send(:include, ThecoreUiRailsAdminUser)
    end
end