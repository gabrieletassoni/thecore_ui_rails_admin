# Changelog

## [3.5.10] - 2026-06-16

### Added
- `push_notification_test` RailsAdmin root action: lets admins send test Web Push notifications to selected active `PushSubscriber` records.
  - GET renders a form with a multi-select checkbox list of all active subscribers (from `PushSubscriber.active`) and fields for title (required), body (required), url (optional), icon (optional).
  - POST validates that title is present; on success creates a `PushMessage` per selected subscriber and calls `ThecoreBackendCommons::PushNotificationService.dispatch`; redirects with a flash success message. On blank title, re-renders the form with a flash error and HTTP 422.
  - View: `app/views/rails_admin/main/push_notification_test.html.erb`
  - Action file: `lib/root_actions/push_notification_test.rb`
  - Registered in `config/initializers/after_initialize.rb`
