RailsAdmin::Config::Actions.add_action "grafana", :base, :root do
    show_in_sidebar true
    show_in_navigation false
    breadcrumb_parent [nil]
    # This ensures the action only shows up for Users
    # visible? authorized?
    # Not a member action
    member false
    # Not a colleciton action
    collection false
    
    link_icon 'fas fa-chart-line'

    http_methods [:get]
    # Adding the controller which is needed to compute calls from the ui
    controller do
        proc do # This is needed because we need that this code is re-evaluated each time is called
            puts "Loading Grafana Controller"
        end
    end
end