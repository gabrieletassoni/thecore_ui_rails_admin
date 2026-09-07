# CLAUDE.md — thecore_ui_rails_admin

Rails engine gem that wires [RailsAdmin](https://github.com/railsadminteam/rails_admin) into a
Thecore host application: authentication/authorization glue (Devise + CanCanCan), a base
controller with shared error handling, per-model RailsAdmin configuration concerns for the core
auth/backend-commons models, custom root/member/collection actions, i18n locales, and (as of
this gem's latest feature) a default `navigation_label`/`navigation_icon` for any model that
doesn't bring its own concern. It lives as a git submodule inside a parent Thecore application.

## Commands

```bash
# Run tests (from inside the submodule directory)
env -u DATABASE_URL BUNDLE_GEMFILE=Gemfile RAILS_ENV=test bundle exec ruby -Itest test/thecore_ui_rails_admin_test.rb

# Bundle install
BUNDLE_GEMFILE=Gemfile bundle install
```

**Important**: always unset `DATABASE_URL` — the devcontainer environment sets it to a
PostgreSQL URL that overrides the test SQLite3 config in `test/dummy`.

## Architecture

### Entry point

`lib/thecore_ui_rails_admin.rb` requires the engine (`lib/thecore_ui_rails_admin/engine.rb`,
a bare `Rails::Engine` subclass with no custom hooks of its own — all wiring happens via
`config/initializers/*.rb`, loaded automatically by Rails' engine boot process).

### `config/initializers/after_initialize.rb` — the wiring hub

This is where most of the gem's runtime behavior actually attaches, inside a single
`config.after_initialize` block (so host-app models/`ApplicationController` are guaranteed to
already be loaded):

- Includes `ConcernCommonApplicationController`/`ConcernRAApplicationController` into
  `ApplicationController` and `RailsAdmin::ApplicationController`.
- Points `RailsAdmin::Config.parent_controller` at `RailsAdminAbstractController`
  (`lib/rails_admin_abstract_controller.rb`) — a plain `ActionController::Base` subclass with
  `rescue_from` handlers for `ActiveRecord::StatementInvalid`/`RecordInvalid`/`RangeError`
  (flashes a friendly message and redirects back to the dashboard instead of a 500 page), plus a
  `before_action` that sets `I18n.locale` from `current_user.locale`.
- Configures Devise (`authenticate_with`/`current_user_method`) and CanCanCan
  (`authorize_with :cancancan`) as RailsAdmin's auth/authz backends.
- Calls `RailsAdmin::Config::Actions.all` once, before requiring any of this gem's own
  root/member/collection action files below. `RailsAdmin::Config::Actions.add_action`'s
  `@@actions ||= []` means whichever caller touches `@@actions` first decides whether the base
  actions (`Dashboard`, `Index`, `Edit`, ...) ever get registered at all — if a custom
  `add_action` call ran first (possible whenever route drawing for the `rails_admin` engine
  mount is lazy relative to this `after_initialize` block, e.g. outside eager-loaded boot), the
  base actions would be silently skipped for the rest of the process, breaking every
  `edit_path`/`index_path`/... helper call anywhere in the app. This call is a no-op once
  `@@actions` is already initialized, so it's safe regardless of the real boot order elsewhere.
- `RailsAdmin::Config.main_app_name` reads `ThecoreSettings ns: :main, key: :app_name` (falls
  back to `ENV["APP_NAME"]`, then `"Thecore"`).
- Excludes ActionText/ActiveStorage/ActionMailbox internal models, plus `UsedToken`
  (`model_driven_api`'s JWT blacklist table) from the RailsAdmin sidebar — the `UsedToken`
  exclusion is wrapped in a `rescue` since `model_driven_api` may not be installed.
- Includes `ExportConcern`/`BulkDeleteConcern` into RailsAdmin's own `Export`/`BulkDelete`
  action classes — both add a `visible?` override so the button only shows on `index` when
  there are records to act on (elsewhere it's always visible, so it isn't stripped from the
  global action list during RailsAdmin's own initialization).
- `include`s each hand-written `ThecoreUiRailsAdmin<ModelName>Concern` into its target model:
  `Role`, `User`, `RoleUser`, `PushSubscriber`, `PushMessage`, `Action`, `PermissionRole`,
  `Permission`, `Predicate`, `Target`, `ThecoreSettings::Setting`.
- `require`s the root/member/collection action files (see below) so
  `RailsAdmin::Config::Actions.add_action` actually registers them.

### Per-model RailsAdmin concerns (`config/initializers/concern_*.rb`)

One file per core model, each an `ActiveSupport::Concern` named `ThecoreUiRailsAdmin<Model>Concern`,
with an `included do rails_admin do ... end end` block setting `navigation_label`/
`navigation_icon`, `configure :field do hide/read_only/required end` for field-level tweaks, and
occasionally `parent`/`create`/`update`-scoped overrides (e.g. `concern_user.rb` hides
Devise-internal columns, requires `password`/`password_confirmation` only on `create`, and hides
them on `update`). These are hand-written, model-specific concerns — the pattern every ATOM/host
model in the ecosystem follows for models that need real field-level configuration (see ADR
0001 in the host app's `vendor/external/thecore/docs/adr/`).

### Default `navigation_label`/icon for models with no concern (`ThecoreUiRailsAdminDefaultNavigationConcern`)

`config/initializers/concern_default_navigation.rb` — per
[ADR 0001](../../../vendor/external/thecore/docs/adr/0001-application-record-defaults-over-generated-concerns.md)
(host app) and GitHub issue `gabrieletassoni/thecore_ui_rails_admin#7`, any `ApplicationRecord`
subclass that does **not** define its own `RailsAdmin::ModelName` concern still gets a sensible
navigation entry instead of RailsAdmin's own unconfigured fallback (no group / no icon):

```ruby
module ThecoreUiRailsAdminDefaultNavigationConcern
  extend ActiveSupport::Concern

  DEFAULT_ICON = 'fa fa-table'.freeze

  included do
    rails_admin do
      navigation_label I18n.t('admin.registries.label')
      navigation_icon ThecoreUiRailsAdminDefaultNavigationConcern::DEFAULT_ICON
    end
  end
end

Rails.application.config.to_prepare do
  ThecoreBackendCommons::DefaultModuleRegistry.register(ThecoreUiRailsAdminDefaultNavigationConcern)
end
```

- **Registered into [`ThecoreBackendCommons::DefaultModuleRegistry`](../thecore_backend_commons/CLAUDE.md#thecorebackendcommonsdefaultmoduleregistry-libthecore_backend_commonsdefault_module_registryrb)**,
  with no `applies_to:` filter (every `ApplicationRecord` subclass). The registry `include`s it
  from `ApplicationRecord.inherited`, at the moment each subclass is defined — installed from
  `config.to_prepare`, not `config.after_initialize`, so it's already in place before Rails
  eager-loads every model in production (`to_prepare` runs before `eager_load!`; installing from
  `after_initialize` would miss every eager-loaded class). `to_prepare` also re-runs on class
  reload in development; `DefaultModuleRegistry.register` is idempotent for the same module
  object, so re-registering on every reload is safe.
- **Only navigation is defaulted.** Field-level configuration (`hide`, `sticky`,
  `configure :field`, custom `list`/`edit` blocks, ...) is deliberately never defaulted — per
  ADR 0001's research, every existing hand-written `RailsAdmin::ModelName` concern in the
  `mytask` engine carries real field-level content, so only the navigation bits above are safe
  to give a generic default. Field-level config stays exclusively in hand-written concerns like
  the ones described above.
- **`navigation_label` intentionally reuses the exact same fixed i18n key**
  (`I18n.t('admin.registries.label')`) that the Thecore VS Code extension's `addModel` template
  (`vendor/external/thecore_code_extension/templates/addModel/rails_admin_concern.rb` in the
  host app) already hardcodes into every freshly generated `RailsAdmin::ModelName` concern — so
  a model relying on this default looks, to an end user, exactly like one whose
  generated-and-never-customized concern was simply kept around. `DEFAULT_ICON` (`fa fa-table`)
  is a real, ready-to-use FontAwesome icon, not a "TODO: customize" placeholder.
- **Why an explicit concern's own `navigation_label`/`navigation_icon` still wins**: this module
  is `include`d from `ApplicationRecord.inherited`, which fires — and so evaluates this
  `included do rails_admin do ... end end` block, registering RailsAdmin's *first* deferred
  config block for that model — before the model class body itself runs its own
  `include RailsAdmin::ModelName` statement, whose block is registered *second*. RailsAdmin
  evaluates same-origin deferred blocks in registration order
  (`RailsAdmin::Config::LazyModel#target`), and `navigation_label`/`navigation_icon` are plain
  last-write-wins setters (`RailsAdmin::Config::Configurable::ClassMethods#register_instance_option`),
  so whichever call runs last — the hand-written concern's, when present — overrides the
  default set here. A model with its own concern therefore still gets this default module
  `include`d (the registry applies unconditionally), but its own field-level config and any
  `navigation_label`/`navigation_icon` it sets always win.
- This requires `ThecoreBackendCommons::DefaultModuleRegistry`, which shipped in
  `thecore_backend_commons` 3.5.0 — the gemspec's existing `>= 3.4` constraint resolves it
  normally from RubyGems now, no pin needed (a temporary `git:`-sourced pin lived in `Gemfile`
  for a while before 3.5.0 was published; it's gone now).
- Covered by the fixtures/tests appended to `test/thecore_ui_rails_admin_test.rb` (see Test
  infrastructure below): a no-concern model gets the default module, its `navigation_label`
  matches the i18n key convention, its `navigation_icon` is the real default (not RailsAdmin's
  own `nil`), an explicit-concern model still includes the default module but its own
  `navigation_label`/`navigation_icon`/field config win.

### Root actions (`lib/root_actions/`)

Registered via `RailsAdmin::Config::Actions.add_action "<name>", :base, :root`, each with its own
`controller do proc do ... end end` block (re-evaluated on every request):

- **`general_computation.rb`** — a generic JSON endpoint (`upsert`/`load` verbs against
  `UserPreference`-style models) used by frontend widgets to persist arbitrary
  per-user/per-model preferences (e.g. saved export field selections), broadcasting the result
  over `ActionCable` on the `"messages"` channel/topic `:general_computation`. Hidden from the
  sidebar/navigation (`show_in_sidebar false`).
- **`active_job_monitor.rb`** — admin view into ActiveJob/Sidekiq state.
- **`push_notification_test.rb`** — lets an admin pick one or more active `PushSubscriber`
  records (filterable by email, with a `LARGE_SUBSCRIBER_THRESHOLD = 10` UX cutoff between an
  inline checkbox list and a search box) and fire a real test `PushMessage` via
  `ThecoreBackendCommons::PushNotificationService.dispatch` — see the Web Push section of
  `CLAUDE.md`/README in `thecore_backend_commons`/`model_driven_api` for the full VAPID flow this
  exercises.

### Member/collection actions (`lib/member_actions/`, `lib/collection_actions/`)

- **`change_password.rb`** (member) — visible only when `bindings[:object].is_a?(::User)`;
  `PATCH` updates `password`/`password_confirmation` via the standard `User#update` (so Devise's
  own validations apply, including any host-app customizations like `thecore_auth_commons`'s
  complexity regex). On success, flashes `admin.actions.change_password.success` and redirects
  to the model's `index_path` (unchanged). On failure it does **not** redirect — it sets
  `flash.now[:error]` and re-renders `change_password` with `status: :not_acceptable`, the same
  render-in-place pattern RailsAdmin's own `handle_save_error` uses for `edit`/`new` (see ADR
  [0001](docs/adr/0001-change-password-error-rendering-is-hand-rolled.md) for why this action
  hand-rolls the error/field-highlighting markup instead of reusing RailsAdmin's field-generation
  helpers). Unlike `handle_save_error`, `admin.actions.change_password.error` is a **fixed,
  generic** message ("Warning! Please correct the highlighted field(s) below.") rather than a
  list of `@object.errors.full_messages` — this form only ever has the two password fields, both
  already showing their own errors inline (below), so repeating the exact same message a second
  time in the flash banner produced a visibly duplicated error on screen; a bug reported after
  the first release of this feature. The view (`app/views/rails_admin/main/change_password.html.erb`) shows a password
  requirements disclaimer above the form (`admin.actions.change_password.requirements`,
  localized in `config/locales/{en,it}.thecore_ui_ra.yml`, interpolating `User.password_length.min`
  so the stated minimum always matches whatever the host app's `User` model actually configures —
  this gem never hardcodes or re-derives that value itself) and highlights `password`/
  `password_confirmation` field errors with the same `error`/`has-error`/`help-inline text-danger`
  classes `RailsAdmin::FormBuilder` uses on ordinary `edit`/`new` forms. The two password fields
  are never repopulated with a submitted value, on success or failure, for either field.
- **`test_ldap_server.rb`** (member) — round-trips an LDAP connection test against a configured
  `auth_source`.
- **`import_users_from_ldap.rb`** (member) — present but **not required** from
  `after_initialize.rb` (commented out) — "a bit risky to have it in the UI" per the comment
  there; re-enable deliberately if needed.
- **`save_filters.rb`/`load_filters.rb`** (collection) — persist/restore a RailsAdmin index
  filter set per user/model (`SavedFilter`).

### Controller concerns

- **`ConcernRAApplicationController`** (`concern_r_a_application_controller.rb`) — overrides
  `after_sign_in_path_for`: sets `I18n.locale` from the signed-in user's `locale` field (if
  present), then picks a landing page as the first `:root` action the user `can? :read`,
  optionally overridden by `ThecoreSettings ns: :main, key: :after_sign_in_redirect_to_root_action`
  when that action is actually in the user's allowed set, and otherwise falls back to any
  `stored_location_for(resource)` recorded by Devise/Warden. Signs the user back out (with a
  flash alert) if no root action is authorized at all — rather than leaving them on a broken
  RailsAdmin dashboard they can't use.
- **`ExportConcern`/`BulkDeleteConcern`** (`concern_export.rb`/`concern_bulk_delete.rb`) — see
  above; both override `visible?` identically (records-present-on-index check).

### Abilities (`config/initializers/abilities.rb`)

`Abilities::ThecoreUiRailsAdmin` — a CanCanCan ability class granting `can :access, :rails_admin`
and `can :read, :dashboard` to every user (nil-safe: no user still gets these two), and denying
`create`/`destroy`/`show` on `ThecoreSettings::Setting` and `destroy`/`update`/`edit`/`show` on
`Action` to everyone regardless of role — settings/actions are meant to be seeded/managed
outside the admin UI, not edited freely through it.

### Migrations (`config/initializers/add_to_db_migrations.rb`)

Appends `db/migrate` to `Rails.application.config.paths['db/migrate']` so the host app picks up
this engine's migrations (currently: `SavedFilter`/`UserPreference` tables backing the
save/load-filters collection actions).

### Locales

`config/locales/{en,it}.thecore_ui_ra.yml` — English/Italian translations for RailsAdmin action
labels, error messages, and the `admin.registries.label`/`admin.settings.label` navigation
group keys referenced throughout the concerns above.

## ATOM isolation principle

Like `thecore_backend_commons`, this gem never assumes a specific model's *domain* logic — it
only injects RailsAdmin configuration onto models defined elsewhere (the host app,
`thecore_auth_commons`, `thecore_backend_commons`). The per-model concerns above are the
RailsAdmin half of the same downstream-injection pattern `thecore_backend_commons`'s own
CLAUDE.md documents for `PushSubscriber`/`PushMessage` (`model_driven_api` injects `json_attrs`,
this gem injects `rails_admin` config, each from its own `after_initialize`/`to_prepare` hook —
neither gem depends on the other beyond the shared `thecore_backend_commons` registry).

## Test infrastructure

The dummy app (`test/dummy/`) uses SQLite3. **Its boot had never previously completed against a
full `Bundler.require`** until the default-navigation feature's PR fixed it — worth knowing if
you're chasing a boot failure while working on this gem's tests. The fix, all in
`test/dummy/config/application.rb`:

- **Stubs `config.assets`** — sprockets/propshaft is not in this gem's bundle, but
  `thecore_backend_commons`'s own `config/initializers/application_config.rb` (now a real
  transitive dependency) unconditionally sets `config.assets.prefix` at boot. A `method_missing`-based
  stub class is prepended onto `Rails::Application::Configuration#assets` (mirrors the identical
  stub in `thecore_backend_commons`'s own dummy app).
- **Stubs `ModelDrivenApi.smart_merge`** — `model_driven_api` is not in this gem's bundle, but
  `thecore_backend_commons`'s `BaseApplicationRecordConcern` calls it in an `included do` block
  and can reach real engine models (`User`, `Role`, ...) during eager loading (`CI=true`).
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
  - The `RailsAdmin::Config::Actions.all` ordering fix in `after_initializer.rb` (see above) —
    without it, `edit_path`/`index_path` are undefined in this dummy app's process, because this
    gem's own custom action files happen to load before anything else ever calls
    `RailsAdmin::Config::Actions.all`/`.find`.

`test/thecore_ui_rails_admin_test.rb` carries both the gem's original version-constant smoke
test and the default-navigation fixtures/tests: two real SQLite tables
(`thecore_ui_rails_admin_no_concern_models`, `..._explicit_concern_models`) and two model
classes (one with no `RailsAdmin::ModelName` concern, one simulating a hand-written concern with
its own `navigation_label`/`navigation_icon`/`configure :extra_field do hide end`), asserting
the default-vs-explicit-wins behavior described above end-to-end against real `RailsAdmin.config`
output — not just that the module got `include`d.
