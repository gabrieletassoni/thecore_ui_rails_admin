// Companion JS for the save_filters collection action. The real UI (see
// app/views/rails_admin/main/save_filters.html.erb) is a plain HTML form with no client-side
// behavior of its own -- this file is deliberately inert rather than a copy of the
// thecore:collection_action generator's own button/ActionCable starter script, which would
// wire up event listeners against DOM elements (#save_filters-id/-response/-loader) this page
// never renders and throw on load. Kept as a real file, not skipped, so this action still
// satisfies the generator's own companion-file convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function saveFiltersFunction(event) {
    // Intentionally inert -- see the comment above.
});
