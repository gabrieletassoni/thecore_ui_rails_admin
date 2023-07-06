RailsAdmin::Config::Actions.add_action "change_password", :base, :member do
    
    link_icon 'fas fa-shield'
    
    http_methods [:get, :patch]

    # Visible only for the User model
    visible do
        bindings[:object].is_a?(::User)
    end
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do
            # if it's a form submission, then update the password
            if request.patch?
                if ::User.find(@object.id).update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
                    flash[:success] = I18n.t("admin.actions.change_password.success")
                else
                    # Add errors to the object
                    flash[:error] = I18n.t("admin.actions.change_password.error")
                end
                # Redirect to the object
                redirect_to index_path(model_name: @abstract_model.to_param)
            end
        end
    end
end
