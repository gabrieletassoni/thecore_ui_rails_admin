// Companion JS for the active_job_monitor root action. The real UI (see
// app/views/rails_admin/main/active_job_monitor.html.erb) is a plain iframe embedding the
// Sidekiq web UI, with its own onload="adjustIframe(this)" handler already wired up in
// app/assets/javascripts/rails_admin/custom/ui.js.erb -- this file is deliberately inert
// rather than a copy of the thecore:root_action generator's own button/ActionCable starter
// script, which would wire up event listeners against DOM elements
// (#active_job_monitor-id/-response/-loader) this page never renders and throw on load. Kept
// as a real file, not skipped, so this action still satisfies the generator's own
// companion-file convention (see thecore_ui_rails_admin#9).
document.addEventListener('turbo:load', function activeJobMonitorFunction(event) {
    // Intentionally inert -- see the comment above.
});
