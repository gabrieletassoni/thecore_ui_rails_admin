// Companion JS for the general_computation root action. The real handler (see
// lib/root_actions/general_computation.rb) only ever renders `render json: ...` for a JSON
// request; its view (app/views/rails_admin/main/general_computation.html.erb) carries no real
// content of its own -- this file is deliberately inert rather than a copy of the
// thecore:root_action generator's own button/ActionCable starter script, which would wire up
// event listeners against DOM elements (#general_computation-id/-response/-loader) this page
// never renders and throw on load. Kept as a real file, not skipped, so this action still
// satisfies the generator's own companion-file convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function generalComputationFunction(event) {
    // Intentionally inert -- see the comment above.
});
