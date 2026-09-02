require 'active_support/concern'

# Default RailsAdmin `navigation_label`/`navigation_icon` for any
# `ApplicationRecord` subclass that has no explicit `RailsAdmin::ModelName`
# concern of its own -- see ADR 0001
# (vendor/external/thecore/docs/adr/0001-application-record-defaults-over-generated-concerns.md
# in the host app) and GitHub issue
# gabrieletassoni/thecore_ui_rails_admin#7.
#
# Registered into `ThecoreBackendCommons::DefaultModuleRegistry` below, so
# it is `include`d automatically into every model at class-definition time
# (via `ApplicationRecord.inherited`) instead of requiring a per-model
# `RailsAdmin::ModelName` concern file to be generated just to get these two
# mechanically-derivable values.
#
# Deliberately does NOT default any field-level configuration (`hide`,
# `sticky`, `configure :field`, custom `list`/`edit` blocks, ...) -- per
# ADR 0001's research, every existing hand-written `RailsAdmin::ModelName`
# concern in the `mytask` engine carries real field-level content, so only
# the navigation bits below are safe to default. Field-level config stays
# exclusively in hand-written concerns.
#
# `navigation_label` intentionally reuses the exact SAME fixed i18n key
# (`I18n.t('admin.registries.label')`) that the Thecore VS Code extension's
# `addModel` template
# (vendor/external/thecore_code_extension/templates/addModel/rails_admin_concern.rb
# in the host app) already hardcodes into every freshly generated
# `RailsAdmin::ModelName` concern -- so a model relying on this default
# looks, to an end user, exactly like one whose generated-and-never-customized
# concern was kept around. `DEFAULT_ICON` is a real, ready-to-use FontAwesome
# icon (no "TODO: customize" placeholder needed).
#
# == Why an explicit concern's own `navigation_label`/`navigation_icon` wins
#
# This module is `include`d into a model class from
# `ApplicationRecord.inherited`, which fires -- and so evaluates this
# `included do rails_admin do ... end end` block, registering RailsAdmin's
# *first* deferred config block for that model -- before the model class
# body itself runs its own `include RailsAdmin::ModelName` statement, whose
# block is registered *second*. RailsAdmin evaluates same-origin deferred
# blocks in registration order (see
# `RailsAdmin::Config::LazyModel#target` in the `rails_admin` gem), and
# `navigation_label`/`navigation_icon` are plain last-write-wins setters
# (see `RailsAdmin::Config::Configurable::ClassMethods#register_instance_option`),
# so whichever call runs last -- the hand-written concern's, when present --
# overrides the default set here.
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
  ThecoreBackendCommons::DefaultModuleRegistry.register(
    ThecoreUiRailsAdminDefaultNavigationConcern
  )
end
