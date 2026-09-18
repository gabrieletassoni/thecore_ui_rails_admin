// Companion JS for the push_notification_test root action. The real UI (see
// app/views/rails_admin/main/push_notification_test.html.erb) already wires up its own inline
// <script> against real element ids (#send-push-form, .subscriber-checkbox, #send-push-btn) --
// this file is deliberately inert rather than a copy of the thecore:root_action generator's own
// button/ActionCable starter script, which would wire up event listeners against DOM elements
// (#push_notification_test-id/-response/-loader) this page never renders and throw on load.
// Kept as a real file, not skipped, so this action still satisfies the generator's own
// companion-file convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function pushNotificationTestFunction(event) {
    // Intentionally inert -- see the comment above.
});
