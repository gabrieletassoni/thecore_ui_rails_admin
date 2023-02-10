# This method defines the migrations paths for the engine and adds them to the migrations paths of 
# the parent Rails app by using ActiveRecord::Migrator.migrations_paths.concat.
# migrations_paths = [File.expand_path("../../db/migrate", __dir__)]
# ActiveRecord::Migrator.migrations_paths.concat(migrations_paths)
Rails.application.config.paths['db/migrate'] << File.expand_path("../../db/migrate", __dir__)