module ThecoreUiRailsAdmin
  class Engine < ::Rails::Engine
    # This code makes the static assets present in this 
    # engine available to main app, even if this gem is 
    # just a dependency of another engine
    initializer 'thecore_ui_rails_admin.load_static_assets' do |app|
      # puts "Loading static assets for #{root}"
      app.middleware.use ::ActionDispatch::Static, "#{root}/app"
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
