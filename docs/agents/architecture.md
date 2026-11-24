# Architecture

> Moved verbatim from `CLAUDE.md` on 2026-11-11 (entry point, after_initialize wiring hub, per-model concerns, root/member/collection actions, controller concerns, abilities, migrations, locales, ATOM isolation principle). `CLAUDE.md` points here; keep this file accurate whenever the behaviour it describes changes.

## Entry point

`lib/thecore_ui_rails_admin.rb` requires the engine (`lib/thecore_ui_rails_admin/engine.rb`,
a bare `Rails::Engine` subclass with no custom hooks of its own — all wiring happens via
`config/initializers/*.rb`, loaded automatically by Rails' engine boot process).

## `config/initializers/after_initialize.rb` — the wiring hub

This is where most of the gem's runtime behavior actually attaches, inside a single
`config.after_initialize` block (so host-app models/`ApplicationController` are guaranteed to
already be loaded):

- Points `RailsAdmin::Config.parent_controller` at `RailsAdminAbstractController`
  (`lib/rails_admin_abstract_controller.rb`) — a plain `ActionController::Base` subclass with
  `rescue_from` handlers for `ActiveRecord::StatementInvalid`/`RecordInvalid`/`RangeError`
  (flashes a friendly message and redirects back to the dashboard instead of a 500 page), plus a
  `before_action` that sets `I18n.locale` from `current_user.locale`.
- Then includes `ConcernRAApplicationController` (`after_sign_in_path_for`) into
  `ApplicationController` and `RailsAdmin::ApplicationController`. The order matters: when
  RailsAdmin's controllers are already loaded, `parent_controller=` removes and reloads
  `RailsAdmin::ApplicationController`/`MainController`, dropping anything included or registered
  before it. `ConcernCommonApplicationController` (thecore_ui_commons) goes into the host's
  `ApplicationController` only, never into RailsAdmin's: its `protect_from_forgery prepend: true`
  (default `:null_session`) would replace RailsAdmin's own `with: :exception` (`test/csrf_test.rb`),
  and its `CanCan::AccessDenied` redirect goes to the main-app root, the sign-in page, where Devise
  bounces a signed-in user on and replaces the message with "already signed in". (Before 3.8.8 the
  include sat before `parent_controller=`, so it never took effect.)
- Then registers `RailsAdminAbstractController#handle_access_denied` for `CanCan::AccessDenied` on
  `RailsAdmin::ApplicationController`: a forbidden action redirects back to the referring page, or
  to the dashboard (always readable, see `Abilities::ThecoreUiRailsAdmin`), with the denial as flash
  alert (`test/access_denied_test.rb`). Without it, every forbidden RailsAdmin URL answered 500.
- Known limitation, development only: on a code reload RailsAdmin's `Config.reload!` resets the
  config (including `parent_controller` and `authenticate_with`) and re-runs only the host's
  `config/initializers/rails_admin.rb`, not this `after_initialize`, so the wiring above is not
  re-applied to reloaded RailsAdmin controllers. Production (no reloading) is unaffected.
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

## Per-model RailsAdmin concerns (`config/initializers/concern_*.rb`)

One file per core model, each an `ActiveSupport::Concern` named `ThecoreUiRailsAdmin<Model>Concern`,
with an `included do rails_admin do ... end end` block setting `navigation_label`/
`navigation_icon`, `configure :field do hide/read_only/required end` for field-level tweaks, and
occasionally `parent`/`create`/`update`-scoped overrides (e.g. `concern_user.rb` hides
Devise-internal columns, requires `password`/`password_confirmation` only on `create`, and hides
them on `update`). On `create`, `password` also brings its own `help`
(`ThecoreUiRailsAdminUserConcern.password_help`, from `User.password_length`): Devise 5
declares the length limits as Procs, which RailsAdmin's `generic_help` compares with
Integers, so the default help made the create form answer 500. These are hand-written,
model-specific concerns — the pattern every ATOM/host model in the ecosystem follows for
models that need real field-level configuration (see ADR 0001 in the host app's
`vendor/external/thecore/docs/adr/`).

## Root actions (`lib/root_actions/`)

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
  `ThecoreBackendCommons::PushNotificationService.dispatch` — see `docs/agents/web-push.md` in
  `thecore_backend_commons` and `docs/agents/custom-actions.md` in `model_driven_api` for the full VAPID flow this
  exercises.

## Member/collection actions (`lib/member_actions/`, `lib/collection_actions/`)

- **`change_password.rb`** (member) — visible only when `bindings[:object].is_a?(::User)`;
  `PATCH` updates `password`/`password_confirmation` via the standard `User#update` (so Devise's
  own validations apply, including any host-app customizations like `thecore_auth_commons`'s
  complexity regex). On success, flashes `admin.actions.change_password.success` and redirects
  to the model's `index_path` (unchanged). On failure it does **not** redirect — it sets
  `flash.now[:error]` and re-renders `change_password` with `status: :not_acceptable`, the same
  render-in-place pattern RailsAdmin's own `handle_save_error` uses for `edit`/`new` (see ADR
  [0001](../adr/0001-change-password-error-rendering-is-hand-rolled.md) for why this action
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
- **`test_ldap_server.rb`** (member) — shows the outcome of `LdapServer#test_connection`
  (thecore_auth_commons >= 3.6.5): success only when the admin bind worked, otherwise danger with
  `admin.actions.test_ldap_server.error` and the reason (no admin credentials, refused bind,
  unreachable host). The optional user check (XHR POST with email/password) runs only after a
  successful server test; a `Net::LDAP::Error` or `SystemCallError` (net-ldap's bare
  `Errno::ECONNREFUSED`) there is rescued, anything else is not
  (thecore_ui_rails_admin#17, `test/member_actions/test_ldap_server_test.rb`).
- **`import_users_from_ldap.rb`** (member) — present but **not required** from
  `after_initialize.rb` (commented out) — "a bit risky to have it in the UI" per the comment
  there; re-enable deliberately if needed.
- **`save_filters.rb`/`load_filters.rb`** (collection) — persist/restore a RailsAdmin index
  filter set per user/model (`SavedFilter`). `save_filters` takes the filters from the Referer's
  query string; without one (no Referer, a malformed one, or a list with no filters) GET and POST
  both redirect back to the list with the `admin.actions.save_filters.nothing_to_save` notice
  (MyTask Odoo #6256, `test/collection_actions/save_filters_test.rb`).

## Controller concerns

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

## Abilities (`config/initializers/abilities.rb`)

`Abilities::ThecoreUiRailsAdmin` — a CanCanCan ability class granting `can :access, :rails_admin`
and `can :read, :dashboard` to every user (nil-safe: no user still gets these two), and denying
`create`/`destroy`/`show` on `ThecoreSettings::Setting` and `destroy`/`update`/`edit`/`show` on
`Action` to everyone regardless of role — settings/actions are meant to be seeded/managed
outside the admin UI, not edited freely through it.

## Migrations (`config/initializers/add_to_db_migrations.rb`)

Appends `db/migrate` to `Rails.application.config.paths['db/migrate']` so the host app picks up
this engine's migrations (currently: `SavedFilter`/`UserPreference` tables backing the
save/load-filters collection actions).

## Locales

`config/locales/{en,it}.thecore_ui_ra.yml` — English/Italian translations for RailsAdmin action
labels, error messages, and the `admin.registries.label`/`admin.settings.label` navigation
group keys referenced throughout the concerns above.

## ATOM isolation principle

Like `thecore_backend_commons`, this gem never assumes a specific model's *domain* logic — it
only injects RailsAdmin configuration onto models defined elsewhere (the host app,
`thecore_auth_commons`, `thecore_backend_commons`). The per-model concerns above are the
RailsAdmin half of the same downstream-injection pattern `thecore_backend_commons`'s
`docs/agents/web-push.md` documents for `PushSubscriber`/`PushMessage` (`model_driven_api` injects `json_attrs`,
this gem injects `rails_admin` config, each from its own `after_initialize`/`to_prepare` hook —
neither gem depends on the other beyond the shared `thecore_backend_commons` registry).
