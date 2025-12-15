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
      # From the UI the user can test if the ldap server is reachable and receive a response
      if request.get? || request.post?
        @ldap = ::LdapServer.find(@object.id)
        # begin
        @ldap.test_connection
        @status = "success"

        @message = I18n.t("admin.actions.test_ldap_server.success")

        # If in the form an email and password are provided, try to authenticate
        if params[:email].present? && params[:password].present?
          Rails.logger.debug("LDAP Test: Attempting to authenticate user #{params[:email]}")
          authenticator = Ldap::Authenticator.new(
            email: params[:email],
            password: params[:password],
          )
          @ldap_user = authenticator.auth_on_single_server(@ldap)
          Rails.logger.debug("LDAP Test: Authentication result for user #{params[:email]}: #{@ldap_user.inspect}")
          # If @ldap_user exists, authentication succeeded
          if @ldap_user
            @message += " " + I18n.t("admin.actions.test_ldap_server.auth_success", email: params[:email])
          else
            @message += " " + I18n.t("admin.actions.test_ldap_server.auth_failure", email: params[:email])
            @status = "warning"
          end
        end
        # rescue => e
        #   @message = I18n.t("admin.actions.test_ldap_server.error", error: e.message)
        #   @status = "danger"
        # end
        # Redirect to the object
        # redirect_to index_path(model_name: @abstract_model.to_param)
      end
    end
  end
end
