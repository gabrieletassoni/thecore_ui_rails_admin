require "test_helper"
require_relative "support/rails_admin_request_tables"

# RailsAdmin, a cookie session, refuses a POST without the authenticity token with 422, as
# RailsAdmin::ApplicationController's own `protect_from_forgery with: :exception` does. Including
# ConcernCommonApplicationController into it once replaced that with its `prepend: true`
# :null_session default, which runs the POST signed out instead (MyTask Odoo #6255).
class CsrfTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in User.create!(email: "admin@example.com", password: "Sup3r$ecret", password_confirmation: "Sup3r$ecret", admin: true)
    @forgery_protection_was = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown { ActionController::Base.allow_forgery_protection = @forgery_protection_was }

  test "a POST without the authenticity token is refused with 422" do
    post rails_admin.new_path(model_name: "user"), params: { user: { email: "csrf@example.com" } }

    assert_response :unprocessable_entity
    assert_nil User.find_by(email: "csrf@example.com")
  end
end
