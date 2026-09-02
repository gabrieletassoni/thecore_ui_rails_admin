This is part of [Thecore framework](https://github.com/gabrieletassoni/thecore/tree/release/3).

---

## Default `navigation_label`/icon for models without a `RailsAdmin::ModelName` concern

Per [ADR 0001](https://github.com/gabrieletassoni/thecore/blob/release/3/docs/adr/0001-application-record-defaults-over-generated-concerns.md)
(host app), any `ApplicationRecord` subclass that does **not** define its own
`RailsAdmin::ModelName` concern still gets a sensible `navigation_label` and
a real default icon (`fa fa-table`) in the RailsAdmin sidebar, instead of
falling back to RailsAdmin's own unconfigured default (no group / no icon).

This is provided by `ThecoreUiRailsAdminDefaultNavigationConcern`
(`config/initializers/concern_default_navigation.rb`), registered into
[`ThecoreBackendCommons::DefaultModuleRegistry`](../thecore_backend_commons/README.md)
so it is included automatically into every model at class-definition time —
no generated concern file required.

The default `navigation_label` reuses the exact same i18n key
(`I18n.t('admin.registries.label')`) that the Thecore VS Code extension's
`addModel` command already hardcodes into every freshly generated
`RailsAdmin::ModelName` concern, so a model relying on this default reads
identically, to an end user, to one whose generated-and-never-customized
concern was kept around.

**Field-level configuration is never defaulted** — `hide`, `sticky`,
`configure :field`, custom `list`/`edit` blocks, etc. stay exclusively in
hand-written `RailsAdmin::ModelName` concerns. A model that already has its
own concern is unaffected: its own `navigation_label`/`navigation_icon` (if
set) and all field-level config still win over/apply alongside the default.

> **Temporary dependency note**: this feature requires
> `ThecoreBackendCommons::DefaultModuleRegistry`, merged into
> `thecore_backend_commons`'s `release/3` branch but not yet published to
> RubyGems. The `Gemfile` pins a git source for this
> (`github: "gabrieletassoni/thecore_backend_commons", branch: "release/3"`)
> until a real release ships — remove it once `thecore_backend_commons`
> cuts a version satisfying the gemspec's `>= 3.4` constraint.

## Push Notification Test (RailsAdmin root action)

A built-in admin UI for sending Web Push test notifications. It lets you pick one or more active subscribers and fire a real notification immediately — useful for verifying the end-to-end VAPID setup without writing any code.

### Prerequisites

1. `rails db:seed` has run (VAPID keys generated in `ThecoreSettings`).
2. At least one browser has registered a push subscription (via the React client's `subscribeToPush()` — see the [`model_driven_api` README](../model_driven_api/README.md#web-push-vapid-from-a-react-client)).
3. The current RailsAdmin user can `manage :push_message` (or `manage :all`).

### Accessing the action

In RailsAdmin, click **Push Notification Test** in the top navigation bar (root actions area).

### Using the form

| Field | Required | Description |
|-------|----------|-------------|
| Subscribers | Yes | Checkboxes listing all active `PushSubscriber` records — shows endpoint and associated user. Select one or more. |
| Title | Yes | Notification title (shown in bold in the OS notification). |
| Body | Yes | Notification body text. |
| URL | No | URL opened when the user clicks the notification. |
| Icon | No | URL of the notification icon image. |

Click **Send Test** to dispatch. The backend creates one `PushMessage` per selected subscriber and calls `PushNotificationService.dispatch` for each. A flash notice reports how many notifications were sent.

### Troubleshooting

| Symptom | Likely cause |
|---------|-------------|
| No subscribers listed | No browser has called `POST subscribe` yet, or all subscriptions have expired. |
| "Subscriber not found" error | The subscriber expired between page load and submit — reload the page. |
| Notification not delivered | Check `ThecoreSettings vapid.public_key` / `vapid.private_key` are set; check `vapid.contact_email` is a valid `mailto:` address; check the browser's notification permission is "Allow". |
| `IntegrationLog` shows errors | The push service (browser vendor) returned an error — usually 410 (expired) which auto-expires the subscriber, or 400 (malformed VAPID keys). |

### Sending pushes programmatically

The same flow available in the UI can be triggered from anywhere in the backend:

```ruby
subscriber = PushSubscriber.active.find(42)
message = subscriber.push_messages.create!(
  title: "Hello",
  body:  "This is a test notification",
  url:   "https://yourapp.com/tasks/1",
  icon:  "https://yourapp.com/icon-192.png"
)
ThecoreBackendCommons::PushNotificationService.dispatch(subscriber, message)
```

Or via the REST API from a privileged client (see [`send_push` in the model_driven_api README](../model_driven_api/README.md#step-5--send-a-push-from-the-backend-optional)).
