Rails.application.configure do
    config.after_initialize do
        User.send(:include, ThecoreUiRailsAdminUser)
    end
end