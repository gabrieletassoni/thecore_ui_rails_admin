require "test_helper"

require_relative "../support/rails_admin_request_tables"

class ChangePasswordActionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "admin@example.com", password: "Sup3r$ecret", password_confirmation: "Sup3r$ecret", admin: true)
    sign_in @user

    # The dummy app has no working asset pipeline (see thecore_ui_rails_admin's
    # docs/agents/test-infrastructure.md: sprockets/propshaft/importmap-rails are all absent from
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

  test "PATCH failure does not repeat a field's specific error text in both the flash banner and inline" do
    patch rails_admin.change_password_path(model_name: "user", id: @user.id),
          params: { user: { password: "Vali3d$Pass", password_confirmation: "Different1$" } }

    assert_response :not_acceptable
    flash_banner = css_select("div.alert-danger").first.text
    inline_error = css_select(".help-inline.text-danger").first.text

    assert_includes inline_error, "match Password"
    refute_includes flash_banner, "match Password"
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
