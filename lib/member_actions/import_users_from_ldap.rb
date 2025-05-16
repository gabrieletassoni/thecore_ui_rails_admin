RailsAdmin::Config::Actions.add_action "import_users_from_ldap", :base, :member do
    
    link_icon 'fas fa-file-import'
    
    http_methods [:get]

    # Visible only for the User model
    visible do
        bindings[:object].is_a?(::LdapServer)
    end
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do
            # call the background job
            BackgroundLdapImportJob.perform_later
            # flash message
            flash[:success] = "✅ Avviato l'import in background degli utenti da #{@object.host}"
            redirect_to back_or_index
        end
    end
end
