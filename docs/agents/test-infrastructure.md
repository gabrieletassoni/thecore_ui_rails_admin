# Test infrastructure

> Moved verbatim from `CLAUDE.md` on 2026-11-11 (dummy app on PostgreSQL, boot fixes, change_password and default-navigation tests). `CLAUDE.md` points here; keep this file accurate whenever the behaviour it describes changes.

The dummy app (`test/dummy/`) runs on **PostgreSQL only** — the only DB target of every Thecore
gem and host app (they use Postgres-specific SQL SQLite cannot exercise); there is no SQLite
config, gem, or database file anymore. `test/dummy/config/database.yml` points at
`thecore_ui_rails_admin_{development,test,production}` (host/port/user/password from
`PGHOST`/`PGPORT`/`PGUSER`/`PGPASSWORD`, defaulting to `db`/`5432`/`postgres`/`postgres`).
Because `DATABASE_URL` overrides `database.yml` and the devcontainer points it at the host app's
own dev database, `test/dummy/config/boot.rb` rewrites any `postgres*` `DATABASE_URL` to keep its
server/credentials but swap the database name for `thecore_ui_rails_admin_<RAILS_ENV>` — in
boot.rb rather than the test helper so every entry point (`bin/rails db:*`, `db:test:prepare`
subprocesses) is covered. The test database must be created once
(`cd test/dummy && RAILS_ENV=test bin/rails db:create`); tables are created by the test files
themselves (`create_table ..., force: true`), there is no dummy `schema.rb`.

Postgres gotcha: a failed statement aborts the surrounding transactional-test transaction even
when Ruby code `rescue`s it, so every later query raises `PG::InFailedSqlTransaction` (SQLite
silently tolerated this). Any table touched on a request path — even behind a `rescue` — must
therefore exist; that's why `change_password_test.rb` creates `thecore_settings` (queried by
`RailsAdmin::Config.main_app_name` on every rendered layout).

**Its boot had never previously completed against a
full `Bundler.require`** until the default-navigation feature's PR fixed it — worth knowing if
you're chasing a boot failure while working on this gem's tests. The fix, all in
`test/dummy/config/application.rb`:

- **Stubs `config.assets`** — sprockets/propshaft is not in this gem's bundle, but
  `thecore_backend_commons`'s own `config/initializers/application_config.rb` (now a real
  transitive dependency) unconditionally sets `config.assets.prefix` at boot. A `method_missing`-based
  stub class is prepended onto `Rails::Application::Configuration#assets` (mirrors the identical
  stub in `thecore_backend_commons`'s own dummy app).
- **No `ModelDrivenApi` stub any more** (3.8.6) — `model_driven_api` is not a dependency of this
  gem, so nothing here may reference it: `Api::UserPreference` uses
  `ThecoreBackendCommons.smart_merge` (thecore_backend_commons >= 3.8, which also stopped calling
  `::ModelDrivenApi`), and the empty scaffolded `Endpoints::UserPreference < NonCrudEndpoints`
  (a `NameError` under eager loading, `CI=true`) was removed — verified in a host app that the
  API/OpenAPI output for user_preferences is unchanged. `test/user_preference_json_attrs_test.rb`
  loads `UserPreference` with no `ModelDrivenApi` defined.
- **Preloads dummy `Ability`/`User`/`ApplicationCable::Connection` models** —
  `thecore_auth_commons`'s own `after_initialize.rb` does
  `Ability.send(:include, ThecoreAuthCommonsCanCanCanConcern)` expecting the *host app* to
  already define `Ability` (it deliberately doesn't define one itself); `thecore_backend_commons`
  similarly expects `User`/`ApplicationCable::Connection`; `thecore_ui_commons`'s
  `config/routes.rb` draws `devise_for :users` against `User`. `test/dummy/app/models/ability.rb`
  and `user.rb` are minimal stand-ins (`Ability`'s own `can :manage, :all` is a fallback only —
  for any *real* signed-in `User`, `thecore_auth_commons`'s `included do def initialize; ...; end
  end` redefines `Ability#initialize` outright, so its actual behavior for an authenticated
  request comes from `Abilities::ThecoreAuthCommons`/`Abilities::ThecoreUiRailsAdmin` plus a real
  `Permission.joins(roles: :users)` lookup — see `change_password_test.rb` below for what that
  requires; `User` just enables `devise :database_authenticatable` and `has_many
  :push_subscribers`). `User` specifically is required inside an
  `ActiveSupport.on_load(:active_record)` callback registered *after* `Bundler.require` (so
  Devise's own `:active_record` load hook — which extends `Devise::Models` onto
  `ActiveRecord::Base` — has already fired) rather than eagerly up front; `require
  "devise/orm/active_record"` is forced first inside that same callback to guarantee
  `ActiveRecord::Base.devise` exists by the time `User`'s class body calls it, regardless of
  Bundler's own require order.
- **`test/member_actions/change_password_test.rb`** — the first test in this gem to drive a real
  authenticated HTTP request through the mounted `rails_admin` engine (every previous test called
  `RailsAdmin.config(...)` directly, never routing/controller/auth). Getting there required
  filling in gaps nothing before it had hit:
  - A `users` table (dummy `User` never had one at all — nothing had ever persisted a `User`
    before), with `locale` (`set_locale`'s `current_user.locale` needs a real, non-nil default —
    `I18n.locale = nil` raises) and `admin` (`Abilities::ThecoreAuthCommons` short-circuits to
    `can :manage, :all` for `user.admin?`, letting the tests skip seeding a working
    Role/Permission graph). Dummy `User` also gained `has_many :role_users`/`has_many :roles,
    through: :role_users` (mirroring `thecore_auth_commons`'s real `User`), and the empty
    `permissions`/`permission_roles`/`roles`/`role_users` tables `Permission.joins(roles: :users)`
    still needs to join through even when nothing seeds them.
  - `RailsAdmin::MainController.layout "rails_admin/content"` for the duration of the test class
    — the dummy app has no working asset pipeline (see the `config.assets` stub above), so
    `layouts/rails_admin/application`'s `_head` partial raises regardless of `asset_source`
    (every source RailsAdmin supports needs a real gem/config this dummy bundle doesn't have).
    `layouts/rails_admin/content` is the inner layout `application` itself renders — it carries
    the flash box (what a validation-error assertion needs) without touching `_head`.
  - The `RailsAdmin::Config::Actions.all` ordering fix in `after_initializer.rb` (see `docs/agents/architecture.md`) —
    without it, `edit_path`/`index_path` are undefined in this dummy app's process, because this
    gem's own custom action files happen to load before anything else ever calls
    `RailsAdmin::Config::Actions.all`/`.find`.

`test/thecore_ui_rails_admin_test.rb` carries both the gem's original version-constant smoke
test and the default-navigation fixtures/tests: two real Postgres tables
(`thecore_ui_rails_admin_no_concern_models`, `..._explicit_concern_models`) and two model
classes (one with no `RailsAdmin::ModelName` concern, one simulating a hand-written concern with
its own `navigation_label`/`navigation_icon`/`configure :extra_field do hide end`), asserting
the default-vs-explicit-wins behavior described in `docs/agents/default-navigation.md` end-to-end against real `RailsAdmin.config`
output — not just that the module got `include`d.
