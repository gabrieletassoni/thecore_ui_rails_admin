require 'uri'

RailsAdmin::Config::Actions.add_action "save_filters", :base, :collection do
    link_icon 'fas fa-floppy-disk'
    
    http_methods [:get, :post]

    # Visible only for the User model
    visible do
        authorized?
    end
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do # This is needed because we need that this code is re-evaluated each time is called
            if request.post?
                SavedFilter.create!(
                    abstract_model_name: @abstract_model,
                    name: params[:filter_name],
                    query_string: request.referer.split('?')[1] # Get filters from referrer
                )
                flash[:success] = "Filter saved!"
                redirect_to back_or_index
            else
                @query_string = request.referer.split('?')[1] # Get filters from referrer
                @query_html = RailsAdminFilterControllerHelper.filters_html_list(@query_string, @abstract_model).html_safe
                @model_name = @abstract_model
                render :save_filter
            end
        end
    end
end