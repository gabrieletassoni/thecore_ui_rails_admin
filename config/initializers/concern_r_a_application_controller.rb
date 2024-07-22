puts "RAApplicationController Concern from ThecoreUiRailsAdmin"
require 'active_support/concern'

module ConcernRAApplicationController
  extend ActiveSupport::Concern
  
  included do
    # Redirects on successful sign in
    def after_sign_in_path_for resource
      puts "after_sign_in_path_for #{resource}"
      root_actions = RailsAdmin::Config::Actions.all(:root).select {|action| can? :read, action.action_name }.collect(&:action_name)
      
      # Default root action as landing page: the first to which I have authorization to read
      action = root_actions.first
      puts "after_sign_in_path_for action: #{action}"
      # Otherwise, if I set a Manual override for landing actions in config, I can test if I'm authorized to see it
      override_landing_page = Settings.ns(:main).after_sign_in_redirect_to_root_action
      action = override_landing_page.to_sym if !override_landing_page.blank? && root_actions.include?(override_landing_page.to_sym)
      
      # If I ask for a specific page, Let's try to go back there if I need to login or re-login
      # This takes precedence on automatic computed action
      stored_location = stored_location_for(resource)
      puts "after_sign_in_path_for stored_location: #{stored_location}"
      if !stored_location.blank? && can?(resource, :all)
        # Go to the latest navigated page
        puts "after_sign_in_path_for Redirect to stored_location"
        return stored_location
      elsif action
        path = rails_admin.send("#{action}_path").sub("#{ENV['RAILS_RELATIVE_URL_ROOT']}#{ENV['RAILS_RELATIVE_URL_ROOT']}", "#{ENV['RAILS_RELATIVE_URL_ROOT']}")
        puts "after_sign_in_path_for Redirect to action #{path}"
        return path
      else
        puts "after_sign_in_path_for ERROR! Signing out user :-("
        sign_out current_user
        user_session = nil
        current_user = nil
        flash[:alert] = "Your user is not authorized to access any page."
        flash[:notice] = nil
        return root_path
      end
    end
  end
end