require "test_helper"
require "minitest/mock"
require_relative "../support/rails_admin_request_tables"

# test_ldap_server shows whether the admin bind really worked: danger with the reason when it did
# not, success only when it did, never a 500 (thecore_ui_rails_admin#17).
class TestLdapServerActionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Stands in for Net::LDAP: answers bind, and get_operation_result like net-ldap's OpenStruct.
  FakeLdap = Struct.new(:bind, :reason, keyword_init: true) do
    def get_operation_result = Struct.new(:message).new(reason)
  end

  setup do
    sign_in User.create!(email: "admin@example.com", password: "Sup3r$ecret", password_confirmation: "Sup3r$ecret", admin: true)
    @server = LdapServer.create!(host: "ldap.example.com", port: 389, base_dn: "dc=example,dc=com",
                                 admin_user: "cn=admin,dc=example,dc=com", admin_password: "secret")
    # The dummy app has no asset pipeline, so the full RailsAdmin layout's `_head` raises: render
    # the inner `rails_admin/content` layout instead (docs/agents/test-infrastructure.md).
    @original_layout = RailsAdmin::MainController._layout
    RailsAdmin::MainController.layout "rails_admin/content"
  end

  teardown { RailsAdmin::MainController.layout @original_layout }

  def server_test_path = rails_admin.test_ldap_server_path(model_name: "ldap_server", id: @server.id)

  def open_test_page
    get server_test_path
  end

  test "a server without admin credentials shows the failure and why" do
    @server.update!(admin_user: nil, admin_password: nil)

    open_test_page

    assert_response :success
    assert_select "div.bg-danger", text: "The LDAP server test failed: No admin user and password are configured for this server"
  end

  test "a host refusing the connection shows the failure and the connection error" do
    @server.update!(host: "127.0.0.1", port: 1)

    open_test_page

    assert_response :success
    assert_select "div.bg-danger", text: /\AThe LDAP server test failed: Connection refused/
  end

  test "a wrong admin password shows the failure, not success" do
    Net::LDAP.stub(:new, FakeLdap.new(bind: false, reason: "Invalid Credentials")) { open_test_page }

    assert_response :success
    assert_select "div.bg-danger", text: "The LDAP server test failed: Invalid Credentials"
    assert_select "div.bg-success", count: 0
  end

  test "correct admin credentials show success" do
    Net::LDAP.stub(:new, FakeLdap.new(bind: true)) { open_test_page }

    assert_response :success
    assert_select "div.bg-success", text: "The LDAP server is reachable"
  end

  test "a user is not authenticated against a server that failed its test" do
    Ldap::Authenticator.stub(:new, ->(**) { flunk "no user authentication expected" }) do
      Net::LDAP.stub(:new, FakeLdap.new(bind: false, reason: "Invalid Credentials")) do
        post server_test_path, params: { email: "someone@example.com", password: "whatever" }, xhr: true
      end
    end

    assert_response :success
  end

  # The XHR answer (test_ldap_server.js.erb) only shows or hides the user details, never the
  # message: rewriting it is out of scope (#17).
  test "an LDAP error while authenticating the user is no 500 and shows no user" do
    failing = Object.new
    failing.define_singleton_method(:auth_on_single_server) { |_server| raise Net::LDAP::Error, "connection reset" }

    Ldap::Authenticator.stub(:new, failing) do
      Net::LDAP.stub(:new, FakeLdap.new(bind: true)) do
        post server_test_path, params: { email: "someone@example.com", password: "whatever" }, xhr: true
      end
    end

    assert_response :success
    assert_includes response.body, '$("#ldap-user-details").addClass("visually-hidden");'
  end
end
