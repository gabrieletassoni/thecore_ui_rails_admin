RailsAdmin::Config::Actions.add_action "test_ldap_server", :base, :member do
  link_icon "fas fa-circle-check"

  http_methods [:get, :post]

  # Visible only for the User model
  visible do
    bindings[:object].is_a?(::LdapServer)
  end
  # Adding the controller which is needed to compute calls from the ui
  controller do
    proc do
      @ldap = ::LdapServer.find(@object.id)
      # begin
      @ldap.test_connection
      @status = "success"

      @message = I18n.t("admin.actions.test_ldap_server.success")

      # From the UI the user can test if the ldap server is reachable and receive a response
      if request.xhr? && request.post? && params[:email].present? && params[:password].present?
        Rails.logger.debug("LDAP Test: Attempting to authenticate user #{params[:email]}")
        authenticator = Ldap::Authenticator.new(
          email: params[:email],
          password: params[:password],
        )
        @ldap_user = authenticator.auth_on_single_server(@ldap)
        @ldap_attributes = {}

        if @ldap_user.present?
          @ldap_user.each_attribute do |key, values|
            safe_values = values.map do |v|
              s = v.to_s

              # 1. Declare UTF-8
              s.force_encoding("UTF-8")

              # 2. Replace invalid / undefined bytes
              s.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "�")

              s
            end

            @ldap_attributes[key] = safe_values
          end
          Rails.logger.debug("LDAP Test: Authentication result for user #{params[:email]}: #{@ldap_user.inspect}")

          @message += " " + I18n.t("admin.actions.test_ldap_server.auth_success", email: params[:email])
        else
          @message += " " + I18n.t("admin.actions.test_ldap_server.auth_failure", email: params[:email])
          @status = "warning"
        end
        # else
        # rescue => e
        #   @message = I18n.t("admin.actions.test_ldap_server.error", error: e.message)
        #   @status = "danger"
        # end
      end
    end
  end
end
