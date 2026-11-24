require "test_helper"
require_relative "../support/rails_admin_request_tables"

# save_filters reads the filters to save from the Referer's query string. Without a Referer, or
# with one that carries no filters, it goes back to the list with a notice instead of a 500
# (MyTask Odoo #6256).
class SaveFiltersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  NOTHING_TO_SAVE = "There are no filters to save: apply some filters to the list first."
  FILTERS = "f%5Bemail%5D%5B1%5D%5Bo%5D=like&f%5Bemail%5D%5B1%5D%5Bv%5D=admin"

  setup do
    sign_in User.create!(email: "admin@example.com", password: "Sup3r$ecret", password_confirmation: "Sup3r$ecret", admin: true)
    # The dummy app has no asset pipeline, so the full RailsAdmin layout's `_head` raises: render
    # the inner `rails_admin/content` layout instead (docs/agents/test-infrastructure.md).
    @original_layout = RailsAdmin::MainController._layout
    RailsAdmin::MainController.layout "rails_admin/content"
  end

  teardown { RailsAdmin::MainController.layout @original_layout }

  test "opening save_filters without a Referer goes back to the list with a notice" do
    get rails_admin.save_filters_path(model_name: "user")

    assert_redirected_to rails_admin.index_path(model_name: "user")
    assert_equal NOTHING_TO_SAVE, flash[:notice]
  end

  test "saving without a Referer creates no filter and goes back to the list with a notice" do
    post rails_admin.save_filters_path(model_name: "user"), params: { filter_name: "Admins" }

    assert_redirected_to rails_admin.index_path(model_name: "user")
    assert_equal NOTHING_TO_SAVE, flash[:notice]
    assert_equal 0, SavedFilter.count
  end

  test "opening save_filters from a list with no filters goes back to the list with a notice" do
    get rails_admin.save_filters_path(model_name: "user"), headers: { "Referer" => rails_admin.index_url(model_name: "user") }

    assert_redirected_to rails_admin.index_path(model_name: "user")
    assert_equal NOTHING_TO_SAVE, flash[:notice]
  end

  test "opening save_filters from a filtered list shows the form" do
    get rails_admin.save_filters_path(model_name: "user"), headers: { "Referer" => "#{rails_admin.index_url(model_name: "user")}?#{FILTERS}" }

    assert_response :success
    assert_select "input[name=filter_name]"
    assert_select "input[name=query_string][value=?]", FILTERS
  end

  test "saving from a filtered list stores that list's filters" do
    post rails_admin.save_filters_path(model_name: "user"), params: { filter_name: "Admins" },
                                                            headers: { "Referer" => "#{rails_admin.index_url(model_name: "user")}?#{FILTERS}" }

    assert_redirected_to rails_admin.index_path(model_name: "user")
    saved = SavedFilter.sole
    assert_equal "Admins", saved.name
    assert_equal FILTERS, saved.query_string
  end

  test "a malformed Referer goes back to the list with a notice" do
    get rails_admin.save_filters_path(model_name: "user"), headers: { "Referer" => "http://exa mple.com/?#{FILTERS}" }

    assert_redirected_to rails_admin.index_path(model_name: "user")
    assert_equal NOTHING_TO_SAVE, flash[:notice]
  end
end
