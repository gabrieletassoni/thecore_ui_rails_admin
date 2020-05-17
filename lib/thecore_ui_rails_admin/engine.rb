module ThecoreUiRailsAdmin
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets", "thecore_ui_rails_admin")
    end
    initializer 'thecore_ui_rails_admin.add_to_migrations' do |app|
      unless app.root.to_s.match root.to_s
        # APPEND TO MAIN APP MIGRATIONS FROM THIS GEM
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
