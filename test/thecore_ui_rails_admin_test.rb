require "test_helper"

class ThecoreUiRailsAdminTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert ThecoreUiRailsAdmin::VERSION
  end
end

# --- Fixtures for the default navigation_label/icon scenario --------------
#
# GitHub issue gabrieletassoni/thecore_ui_rails_admin#7 / ADR 0001
# (vendor/external/thecore/docs/adr/0001-application-record-defaults-over-generated-concerns.md
# in the host app): a model with no explicit `RailsAdmin::ModelName` concern
# should still get a sensible `navigation_label`/`navigation_icon` via
# `ThecoreUiRailsAdminDefaultNavigationConcern`, registered into
# `ThecoreBackendCommons::DefaultModuleRegistry` from
# config/initializers/concern_default_navigation.rb.
#
# Real (if minimal) SQLite tables are created here -- rather than relying on
# a dummy-app migration -- because RailsAdmin's field-level config
# (`configure`/`.fields`) needs real columns to introspect; a table-less
# model raises inside RailsAdmin's `AbstractModel` construction.
ActiveRecord::Base.connection.create_table(:thecore_ui_rails_admin_no_concern_models, force: true) do |t|
  t.string :name
end

ActiveRecord::Base.connection.create_table(:thecore_ui_rails_admin_explicit_concern_models, force: true) do |t|
  t.string :name
  t.string :extra_field
end

# No explicit `RailsAdmin::ModelName` concern of its own -- relies entirely
# on the default applied automatically via `ApplicationRecord.inherited`
# (`ThecoreBackendCommons::DefaultModuleRegistry`).
class ThecoreUiRailsAdminNoConcernModel < ApplicationRecord
end

# Simulates a hand-written `RailsAdmin::ModelName` concern, as the Thecore
# VS Code extension's `addModel` template would generate (and then get
# customized) -- its own `navigation_label`/`navigation_icon`, plus real
# field-level config (`configure :field do hide end`).
module RailsAdmin::ThecoreUiRailsAdminExplicitConcernModel
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label "Custom Explicit Label"
      navigation_icon "fa fa-custom-icon"

      configure :extra_field do
        hide
      end
    end
  end
end

class ThecoreUiRailsAdminExplicitConcernModel < ApplicationRecord
  include RailsAdmin::ThecoreUiRailsAdminExplicitConcernModel
end

class ThecoreUiRailsAdminDefaultNavigationConcernTest < ActiveSupport::TestCase
  test "a model with no explicit RailsAdmin::ModelName concern includes the default navigation concern" do
    assert ThecoreUiRailsAdminNoConcernModel.include?(ThecoreUiRailsAdminDefaultNavigationConcern)
  end

  test "its navigation_label matches the i18n key convention the VS Code extension's addModel template already uses" do
    config = RailsAdmin.config(ThecoreUiRailsAdminNoConcernModel)
    assert_equal I18n.t("admin.registries.label"), config.navigation_label
  end

  test "its navigation_icon is a real default, not RailsAdmin's own unconfigured nil fallback" do
    config = RailsAdmin.config(ThecoreUiRailsAdminNoConcernModel)
    refute_nil config.navigation_icon
    assert_equal ThecoreUiRailsAdminDefaultNavigationConcern::DEFAULT_ICON, config.navigation_icon
  end

  test "a model with its own RailsAdmin::ModelName concern still includes the default module (registry applies unconditionally)" do
    assert ThecoreUiRailsAdminExplicitConcernModel.include?(ThecoreUiRailsAdminDefaultNavigationConcern)
  end

  test "a model with its own concern has its explicit navigation_label/navigation_icon win over the default" do
    config = RailsAdmin.config(ThecoreUiRailsAdminExplicitConcernModel)
    assert_equal "Custom Explicit Label", config.navigation_label
    assert_equal "fa fa-custom-icon", config.navigation_icon
  end

  test "a model with its own concern still applies its own field-level config" do
    config = RailsAdmin.config(ThecoreUiRailsAdminExplicitConcernModel)
    field = config.fields.detect { |f| f.name == :extra_field }

    assert field, "expected :extra_field to be a configured field"
    assert field.hidden?
  end
end
