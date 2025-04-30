require 'uri'

RailsAdmin::Config::Actions.add_action "load_filters", :base, :collection do
    link_icon 'fas fa-upload'
    
    http_methods [:get, :delete]

    # Visible only for the User model
    visible do
        authorized?
    end
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do # This is needed because we need that this code is re-evaluated each time is called
            # Load all the filters which have the current abstract_model_name
            if params[:id_to_delete]
                # Delete the filter
                @saved_filter = SavedFilter.find(params[:id_to_delete])
                @saved_filter.destroy
                flash[:success] = "Filter deleted!"
                # redirect_to back_or_index
            end
            # Load the filter
            Rails.logger.debug "Loading filters for model: #{params[:model_name]}"
            @saved_filters = SavedFilter.where(abstract_model_name: params[:model_name].classify)
            Rails.logger.debug "Saved filters: #{@saved_filters.inspect}"
        end
    end
end