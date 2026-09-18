// Companion JS for the test_ldap_server member action. The real view (see
// app/views/rails_admin/main/test_ldap_server.html.erb) already wires up its own inline
// <script> against real element ids (#test-connection, #spinner, #ldap-user-details, ...) --
// this file is deliberately inert rather than a copy of the thecore:member_action generator's
// own button/XHR starter script, which would wire up event listeners against DOM elements
// (#test_ldap_server-id/-response) this page never renders and throw on load. Kept as a real
// file, not skipped, so this action still satisfies the generator's own companion-file
// convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function testLdapServerFunction(event) {
    // Intentionally inert -- see the comment above.
});
