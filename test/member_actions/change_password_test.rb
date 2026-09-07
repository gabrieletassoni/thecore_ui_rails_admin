require "test_helper"

# `users` never had a backing table in the dummy app -- its User model
# existed only so other engines' `include`/route-drawing calls had
# something to find (see test/dummy/app/models/user.rb). Created here, the
# first place that actually needs to persist a User, so these tests can
# exercise real Devise validations end-to-end.
ActiveRecord::Base.connection.create_table(:users, force: true) do |t|
  t.string :email, default: ""
  t.string :encrypted_password, default: ""
  # `set_locale` (lib/rails_admin_abstract_controller.rb) does
  # `I18n.locale = current_user.locale` unconditionally for any signed-in
  # user -- a nil locale would raise I18n::InvalidLocale, so this needs a
  # real default, matching the production User's `locale` field.
  t.string :locale, default: "en"
  # `Abilities::ThecoreAuthCommons` grants `can :manage, :all` outright for
  # `user.admin?` -- true here so these tests don't also need to seed a
  # working Role/Permission graph, only the empty join tables below (so
  # `ThecoreAuthCommonsCanCanCanConcern#initialize`'s unconditional
  # `Permission.joins(roles: :users)` lookup has something to query).
  t.boolean :admin, default: false
end

%i[permissions permission_roles roles role_users].each do |table_name|
  ActiveRecord::Base.connection.create_table(table_name, force: true) do |t|
    t.integer :permission_id if table_name == :permission_roles
    t.integer :role_id if %i[permission_roles role_users].include?(table_name)
    t.integer :user_id if table_name == :role_users
  end
end

class ChangePasswordActionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "admin@example.com", password: "Sup3r$ecret", password_confirmation: "Sup3r$ecret", admin: true)
    sign_in @user

    # The dummy app has no working asset pipeline (see thecore_ui_rails_admin's
    # own CLAUDE.md: sprockets/propshaft/importmap-rails are all absent from
    # this gem's bundle), so `layouts/rails_admin/application`'s `_head`
    # partial blows up on the asset tags regardless of `asset_source`.
    # `layouts/rails_admin/content` is the inner layout application.html.erb
    # itself renders -- it carries the flash box (what "evidenziando
    # l'errore come fa rails_admin" means here) without needing `_head`.
    @original_layout = RailsAdmin::MainController._layout
    RailsAdmin::MainController.layout "rails_admin/content"
  end

  teardown do
    RailsAdmin::MainController.layout @original_layout
  end

  test "GET change_password shows the password requirements disclaimer with the configured minimum length" do
    get rails_admin.change_password_path(model_name: "user", id: @user.id)

    assert_response :success
    assert_select ".alert-info", text: I18n.t("admin.actions.change_password.requirements", min_length: User.password_length.min)
  end

  test "PATCH with mismatched confirmation does not redirect, and re-renders the form highlighting the error" do
    patch rails_admin.change_password_path(model_name: "user", id: @user.id),
          params: { user: { password: "Vali3d$Pass", password_confirmation: "Different1$" } }

    assert_response :not_acceptable
    assert_select "div.alert-danger"
    assert_select "div.has-error"
    assert_select ".help-inline.text-danger"
  end

  test "PATCH failure never re-populates the password fields with the submitted values" do
    patch rails_admin.change_password_path(model_name: "user", id: @user.id),
          params: { user: { password: "Vali3d$Pass", password_confirmation: "Different1$" } }

    assert_response :not_acceptable
    refute_includes response.body, "Vali3d$Pass"
    refute_includes response.body, "Different1$"
  end

  test "PATCH with a valid, matching password succeeds and redirects away from the change_password page" do
    patch rails_admin.change_password_path(model_name: "user", id: @user.id),
          params: { user: { password: "Vali3d$Pass", password_confirmation: "Vali3d$Pass" } }

    assert_response :redirect
    refute_includes response.location, "change_password"
    assert @user.reload.valid_password?("Vali3d$Pass")
  end
end
