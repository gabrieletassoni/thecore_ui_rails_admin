RailsAdmin::Config::Actions.add_action "general_computation", :base, :root do
    show_in_sidebar false
    show_in_navigation false
    breadcrumb_parent [nil]
    # This ensures the action only shows up for Users
    # visible? authorized?
    # Not a member action
    member false
    # Not a colleciton action
    collection false
    # Have a look at https://fontawesome.com/v5/search for available icons
    link_icon 'fas fa-file'
    # The controller which will be used to compute the action and the REST verbs it will respond to
    http_methods [:get, :post, :put, :patch, :delete]
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do # This is needed because we need that this code is re-evaluated each time is called
            if request.format.json?
                # PArams sent by the new call are:
                # {
                #     action: "upsert",
                #     model: "UserPreference",
                #     finders: {
                #         user_id: currentUserId,
                #         name: `export_${currentModelName}` 
                #     },
                #     fields: {
                #         value: selectedFields
                #     }
                # }
                # 
                case params[:verb]
                when "upsert"
                    params.permit!
                    result = params[:model].camelize.constantize.where(params[:finders]).first_or_initialize.update(params[:fields])
                    if result
                        status = 200
                        message = "User preference saved"
                    else
                        status = 422
                        message = "Error saving user preference: #{result.errors.full_messages.join(", ")}"
                    end
                when "load"
                    params.permit!
                    result = params[:model].camelize.constantize.where(params[:finders]).first
                    message = result
                    status = result.nil? ? 404 : 200
                end

                # This is the code that is executed when the action is called
                # It is executed in the context of the controller
                # So you can access all the controller methods
                # and instance variables
                ActionCable.server.broadcast("messages", { topic: :general_computation, status: status, message: message})
                render json: {message: message.presence || "No message"}.to_json, status: status.presence || 200
            end
        end
    end
end