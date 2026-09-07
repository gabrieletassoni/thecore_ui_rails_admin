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
                if @object.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
                    flash[:success] = I18n.t("admin.actions.change_password.success")
                    redirect_to index_path(model_name: @abstract_model.to_param)
                else
                    # Stay on the change_password page, highlighting the error the same
                    # way RailsAdmin's own edit/new forms do on a validation failure --
                    # @object keeps its errors for the re-rendered form to read.
                    flash.now[:error] = I18n.t("admin.actions.change_password.error", errors: @object.errors.full_messages.join(', '))
                    render :change_password, status: :not_acceptable
                end
            end
        end
    end
end
