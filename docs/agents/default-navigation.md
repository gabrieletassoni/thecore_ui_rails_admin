# Default navigation label and icon

> Moved verbatim from `CLAUDE.md` on 2026-11-11 (`ThecoreUiRailsAdminDefaultNavigationConcern`, for models with no RailsAdmin concern). `CLAUDE.md` points here; keep this file accurate whenever the behaviour it describes changes.

## Default `navigation_label`/icon for models with no concern (`ThecoreUiRailsAdminDefaultNavigationConcern`)

`config/initializers/concern_default_navigation.rb` — per
[ADR 0001](../../../../../vendor/external/thecore/docs/adr/0001-application-record-defaults-over-generated-concerns.md)
(host app) and GitHub issue `gabrieletassoni/thecore_ui_rails_admin#7`, any `ApplicationRecord`
subclass that does **not** define its own `RailsAdmin::ModelName` concern still gets a sensible
navigation entry instead of RailsAdmin's own unconfigured fallback (no group / no icon):

```ruby
module ThecoreUiRailsAdminDefaultNavigationConcern
  extend ActiveSupport::Concern

  DEFAULT_ICON = 'fa fa-table'.freeze

  included do
    rails_admin do
      navigation_label I18n.t('admin.registries.label')
      navigation_icon ThecoreUiRailsAdminDefaultNavigationConcern::DEFAULT_ICON
    end
  end
end

Rails.application.config.to_prepare do
  ThecoreBackendCommons::DefaultModuleRegistry.register(ThecoreUiRailsAdminDefaultNavigationConcern)
end
```

- **Registered into [`ThecoreBackendCommons::DefaultModuleRegistry`](../../../thecore_backend_commons/docs/agents/default-module-registry.md)**,
  with no `applies_to:` filter (every `ApplicationRecord` subclass). The registry `include`s it
  from `ApplicationRecord.inherited`, at the moment each subclass is defined — installed from
  `config.to_prepare`, not `config.after_initialize`, so it's already in place before Rails
  eager-loads every model in production (`to_prepare` runs before `eager_load!`; installing from
  `after_initialize` would miss every eager-loaded class). `to_prepare` also re-runs on class
  reload in development; `DefaultModuleRegistry.register` is idempotent for the same module
  object, so re-registering on every reload is safe.
- **Only navigation is defaulted.** Field-level configuration (`hide`, `sticky`,
  `configure :field`, custom `list`/`edit` blocks, ...) is deliberately never defaulted — per
  ADR 0001's research, every existing hand-written `RailsAdmin::ModelName` concern in the
  `mytask` engine carries real field-level content, so only the navigation bits above are safe
  to give a generic default. Field-level config stays exclusively in hand-written concerns like
  the ones described in `docs/agents/architecture.md`.
- **`navigation_label` intentionally reuses the exact same fixed i18n key**
  (`I18n.t('admin.registries.label')`) that the Thecore VS Code extension's `addModel` template
  (`vendor/external/thecore_code_extension/templates/addModel/rails_admin_concern.rb` in the
  host app) already hardcodes into every freshly generated `RailsAdmin::ModelName` concern — so
  a model relying on this default looks, to an end user, exactly like one whose
  generated-and-never-customized concern was simply kept around. `DEFAULT_ICON` (`fa fa-table`)
  is a real, ready-to-use FontAwesome icon, not a "TODO: customize" placeholder.
- **Why an explicit concern's own `navigation_label`/`navigation_icon` still wins**: this module
  is `include`d from `ApplicationRecord.inherited`, which fires — and so evaluates this
  `included do rails_admin do ... end end` block, registering RailsAdmin's *first* deferred
  config block for that model — before the model class body itself runs its own
  `include RailsAdmin::ModelName` statement, whose block is registered *second*. RailsAdmin
  evaluates same-origin deferred blocks in registration order
  (`RailsAdmin::Config::LazyModel#target`), and `navigation_label`/`navigation_icon` are plain
  last-write-wins setters (`RailsAdmin::Config::Configurable::ClassMethods#register_instance_option`),
  so whichever call runs last — the hand-written concern's, when present — overrides the
  default set here. A model with its own concern therefore still gets this default module
  `include`d (the registry applies unconditionally), but its own field-level config and any
  `navigation_label`/`navigation_icon` it sets always win.
- This requires `ThecoreBackendCommons::DefaultModuleRegistry`, which shipped in
  `thecore_backend_commons` 3.5.0 — the gemspec's existing `>= 3.4` constraint resolves it
  normally from RubyGems now, no pin needed (a temporary `git:`-sourced pin lived in `Gemfile`
  for a while before 3.5.0 was published; it's gone now).
- Covered by the fixtures/tests appended to `test/thecore_ui_rails_admin_test.rb` (see
  `docs/agents/test-infrastructure.md`): a no-concern model gets the default module, its `navigation_label`
  matches the i18n key convention, its `navigation_icon` is the real default (not RailsAdmin's
  own `nil`), an explicit-concern model still includes the default module but its own
  `navigation_label`/`navigation_icon`/field config win.
