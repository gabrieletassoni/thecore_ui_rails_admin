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
            # The filters to save are the Referer's query string: none (bare URL, new tab, privacy
            # settings, or a list with no filters applied) means nothing to save (MyTask Odoo #6256).
            query_string = begin
                URI(request.referer.to_s).query.presence
            rescue URI::InvalidURIError
                nil
            end
            if query_string.nil?
                flash[:notice] = I18n.t("admin.actions.save_filters.nothing_to_save")
                redirect_to back_or_index
            elsif request.post?
                SavedFilter.create!(
                    abstract_model_name: @abstract_model,
                    name: params[:filter_name],
                    query_string: query_string
                )
                flash[:success] = "Filter saved!"
                redirect_to back_or_index
            else
                @query_string = query_string
                @query_html = RailsAdminFilterControllerHelper.filters_html_list(@query_string, @abstract_model).html_safe
                @model_name = @abstract_model
                render :save_filters
            end
        end
    end
end