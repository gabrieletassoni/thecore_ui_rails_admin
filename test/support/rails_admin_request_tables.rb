# Tables an authenticated request through the mounted rails_admin engine touches, created once per
# process by whichever request test requires this file first.

# `users` never had a backing table in the dummy app -- its User model
# existed only so other engines' `include`/route-drawing calls had
# something to find (see test/dummy/app/models/user.rb). Created here, the
# first place that actually needs to persist a User, so these tests can
# exercise real Devise validations end-to-end.
ActiveRecord::Base.connection.create_table(:users, force: true) do |t|
  t.string :email, default: ""
  t.string :encrypted_password, default: ""
  # `set_locale` (lib/rails_admin_abstract_controller.rb) does
  # `I18n.locale = current_user.locale` unconditionally for any signed-in
  # user -- a nil locale would raise I18n::InvalidLocale, so this needs a
  # real default, matching the production User's `locale` field.
  t.string :locale, default: "en"
  # `Abilities::ThecoreAuthCommons` grants `can :manage, :all` outright for
  # `user.admin?`: tests that create an admin need no Role/Permission graph, only
  # the empty join tables below (so `ThecoreAuthCommonsCanCanCanConcern#initialize`'s
  # unconditional `Permission.joins(roles: :users)` lookup has something to query).
  # A non-admin gets only the gem abilities (e.g. no :create on User).
  t.boolean :admin, default: false
end

%i[permissions permission_roles roles role_users].each do |table_name|
  ActiveRecord::Base.connection.create_table(table_name, force: true) do |t|
    t.integer :permission_id if table_name == :permission_roles
    t.integer :role_id if %i[permission_roles role_users].include?(table_name)
    t.integer :user_id if table_name == :role_users
  end
end

# `RailsAdmin::Config.main_app_name` (config/initializers/after_initialize.rb)
# queries `ThecoreSettings::Setting` on every rendered rails_admin layout. Its
# `rescue` covers a missing table, but on Postgres the failed statement still
# aborts the test's surrounding transaction, so every later query raises
# PG::InFailedSqlTransaction -- the table must exist (columns mirror
# thecore_settings' own CreateThecoreSettings migration).
ActiveRecord::Base.connection.create_table(:thecore_settings, force: true) do |t|
  t.boolean :enabled, default: true
  t.string :kind, null: false, default: "string"
  t.string :ns, default: "main"
  t.string :key, null: false
  t.text :raw
  t.string :label
  t.timestamps
end

# save_filters (lib/collection_actions/save_filters.rb) creates a SavedFilter; columns mirror
# db/migrate (CreateSavedFilters + the model_name -> abstract_model_name rename).
ActiveRecord::Base.connection.create_table(:saved_filters, force: true) do |t|
  t.string :abstract_model_name
  t.string :name
  t.text :query_string
  t.integer :admin_user_id
  t.timestamps
end
