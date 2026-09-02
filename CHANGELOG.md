# Changelog

## [3.8.0] - 2026-09-02

### Added
- **`ThecoreUiRailsAdminDefaultNavigationConcern`** (`config/initializers/concern_default_navigation.rb`) — gives every `ApplicationRecord` subclass a default `navigation_label`/`navigation_icon` in RailsAdmin with no explicit `RailsAdmin::ModelName` concern required, registered into `ThecoreBackendCommons::DefaultModuleRegistry` (requires `thecore_backend_commons ~> 3.5`). Field-level config (`hide`, `sticky`, custom `list`/`edit` blocks) is never defaulted — a model with its own concern is unaffected. See CLAUDE.md for the RailsAdmin deferred-block override mechanics.

### Fixed
- The dummy test app's boot had never previously completed against a full `Bundler.require` — fixed alongside the above (config.assets stub, ModelDrivenApi.smart_merge stub, preloaded dummy Ability/User models). See CLAUDE.md's Test infrastructure section.

## [3.7.0] - 2026-06-30

### Changed
- **`push_notification_test` root action** — improved subscriber load/filter strategy for large datasets:
  - `@subscriber_emails` populated via `pluck(:email)` (strings only) for a native HTML `<datalist>` autocomplete on the email search input — no full AR objects loaded.
  - Initial state shows active subscriber count (`PushSubscriber.active.count`) + localized disclaimer instead of loading all subscribers.
  - Filter via GET (`params[:q]` → `ILIKE` query) — page loads with filtered checkboxes; empty before any search.
  - Two separate forms: GET for filtering, POST for sending.
  - JS confirm alert when > 10 subscribers selected (`LARGE_SUBSCRIBER_THRESHOLD = 10`), message localized in en/it.
  - New i18n keys added under `admin.actions.push_notification_test` in both `en.thecore_ui_ra.yml` and `it.thecore_ui_ra.yml`.

## [3.5.10] - 2026-06-16

### Added
- `push_notification_test` RailsAdmin root action: lets admins send test Web Push notifications to selected active `PushSubscriber` records.
  - GET renders a form with a multi-select checkbox list of all active subscribers (from `PushSubscriber.active`) and fields for title (required), body (required), url (optional), icon (optional).
  - POST validates that title is present; on success creates a `PushMessage` per selected subscriber and calls `ThecoreBackendCommons::PushNotificationService.dispatch`; redirects with a flash success message. On blank title, re-renders the form with a flash error and HTTP 422.
  - View: `app/views/rails_admin/main/push_notification_test.html.erb`
  - Action file: `lib/root_actions/push_notification_test.rb`
  - Registered in `config/initializers/after_initialize.rb`
