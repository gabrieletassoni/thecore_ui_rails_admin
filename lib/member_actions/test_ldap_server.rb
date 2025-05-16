RailsAdmin::Config::Actions.add_action "test_ldap_server", :base, :member do
    
    link_icon 'fas fa-circle-check'
    
    http_methods [:get]

    # Visible only for the User model
    visible do
        bindings[:object].is_a?(::LdapServer)
    end
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do
            # From the UI the user can test if the ldap server is reachable and receive a response
            if request.get?
                ldap = ::LdapServer.find(@object.id)
                begin
                    ldap.test_connection
                    
                    flash[:success] = @message = I18n.t("admin.actions.test_ldap_server.success")
                rescue => e
                    flash[:error] = @message = I18n.t("admin.actions.test_ldap_server.error", error: e.message)
                end
                # Redirect to the object
                redirect_to index_path(model_name: @abstract_model.to_param)
            end
            
        end
    end
end
