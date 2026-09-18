// Companion JS for the import_users_from_ldap member action. The action's own require line in
// config/initializers/after_initialize.rb is deliberately commented out ("a bit risky to have
// it in the UI") -- this action is disabled and its view
// (app/views/rails_admin/main/import_users_from_ldap.html.erb) carries no real content of its
// own -- this file is deliberately inert rather than a copy of the thecore:member_action
// generator's own button/XHR starter script, which would wire up event listeners against DOM
// elements (#import_users_from_ldap-id/-response) this page never renders and throw on load.
// Kept as a real file, not skipped, so this action still satisfies the generator's own
// companion-file convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function importUsersFromLdapFunction(event) {
    // Intentionally inert -- see the comment above.
});
