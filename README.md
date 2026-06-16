This is part of [Thecore framework](https://github.com/gabrieletassoni/thecore/tree/release/3).

---

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
