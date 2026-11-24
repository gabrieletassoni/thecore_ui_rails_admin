require "test_helper"
require_relative "support/rails_admin_request_tables"

# A RailsAdmin action the user may not perform sends them back to where they came from (or to the
# dashboard) with the denial message, instead of a 500 (MyTask Odoo #6255).
class AccessDeniedTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  DENIED = "You are not authorized to access this page."

  setup do
    sign_in User.create!(email: "plain@example.com", password: "Sup3r$ecret", password_confirmation: "Sup3r$ecret")
  end

  test "a forbidden action opened from a page goes back to that page with the denial message" do
    referer = rails_admin.index_url(model_name: "user")
    get rails_admin.new_path(model_name: "user"), headers: { "Referer" => referer }

    assert_redirected_to referer
    assert_equal DENIED, flash[:alert]
  end

  test "a forbidden action opened by its bare URL goes to the dashboard with the denial message" do
    get rails_admin.new_path(model_name: "user")

    assert_redirected_to rails_admin.dashboard_url
    assert_equal DENIED, flash[:alert]
  end
end
