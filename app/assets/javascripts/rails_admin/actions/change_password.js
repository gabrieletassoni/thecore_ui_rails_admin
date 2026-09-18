// Companion JS for the change_password member action. The real view (see
// app/views/rails_admin/main/change_password.html.erb) is a plain hand-rolled form with no
// client-side behavior of its own -- this file is deliberately inert rather than a copy of the
// thecore:member_action generator's own button/XHR starter script, which would wire up event
// listeners against DOM elements (#change_password-id/-response) this page never renders and
// throw on load. Kept as a real file, not skipped, so this action still satisfies the
// generator's own companion-file convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function changePasswordFunction(event) {
    // Intentionally inert -- see the comment above.
});
