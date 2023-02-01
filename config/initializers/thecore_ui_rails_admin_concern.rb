require 'active_support/concern'

module ThecoreUiRailsAdminConcern
  extend ActiveSupport::Concern
  
  included do
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # layout 'thecore'
    protect_from_forgery with: :exception, prepend: true
    rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_url, alert: exception.message
    end
    include HttpAcceptLanguage::AutoLocale
    before_action :store_user_location!, if: :storable_location?
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :reject_locked!, if: :devise_controller?
    
    helper_method :reject_locked!
    helper_method :require_admin!
    helper_method :line_break
    helper_method :title
    helper_method :bootstrap_class_for
    
    # Redirects on successful sign in
    def after_sign_in_path_for resource
      root_actions = RailsAdmin::Config::Actions.all(:root).select {|action| can? action.action_name, :all }.collect(&:action_name)

      # Default root action as landing page: the first to which I have authorization to read
      action = root_actions.first
      # Otherwise, if I set a Manual override for landing actions in config, I can test if I'm authorized to see it
      override_landing_page = Settings.ns(:main).after_sign_in_redirect_to_root_action
      action = override_landing_page.to_sym if !override_landing_page.blank? && root_actions.include?(override_landing_page.to_sym)

      # If I ask for a specific page, Let's try to go back there if I need to login or re-login
      # This takes precedence on automatic computed action
      stored_location = stored_location_for(resource)
      if !stored_location.blank? && can?(resource, :all)
        # Go to the latest navigated page
        return stored_location
      elsif action
        return rails_admin.send("#{action}_path").sub("#{ENV['RAILS_RELATIVE_URL_ROOT']}#{ENV['RAILS_RELATIVE_URL_ROOT']}", "#{ENV['RAILS_RELATIVE_URL_ROOT']}")
      else
        sign_out current_user
        user_session = nil
        current_user = nil
        flash[:alert] = "Your user is not authorized to access any page."
        flash[:notice] = nil
        return root_path
      end
    end
  end
  
  def title value = "Thecore"
    @title = value
  end
  
  def bootstrap_class_for flash_type
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end
  
  def line_break s
    s.gsub("\n", "<br/>")
  end
  # Devise permitted params
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in) { 
      |u| u.permit(
        :username,
        :password,
        :email,
        :login,
        :password_confirmation,
        :remember_me)
      }
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(
        :username,
        :password,
        :email,
        :login,
        :password_confirmation)
      }
      devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(
        :username,
        :email,
        :login,
        :password,
        :password_confirmation,
        :current_password)
      }
    end
    
    # Auto-sign out locked users
    def reject_locked!
      # Rails.logger.info "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB reject_locked"
      if !current_user.blank? && current_user.locked?
        # Rails.logger.info "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB is locked"
        sign_out current_user
        user_session = nil
        current_user = nil
        flash[:alert] = "Your account is locked."
        flash[:notice] = nil
        redirect_to root_url
      end
      # Rails.logger.info "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB is not locked = ok"
    end

    
    # Only permits admin users
    def require_admin!
      authenticate_user!
      
      if current_user && !current_user.admin?
        redirect_to inside_path
      end
    end
    
    # Its important that the location is NOT stored if:
    # - The request method is not GET (non idempotent)
    # - The request is handled by a Devise controller such as 
    #     Devise::SessionsController as that could cause an 
    #     infinite redirect loop.
    # - The request is an Ajax request as this can lead to very unexpected 
    #     behaviour.
    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && is_storable?
    end
    
    def store_user_location!
      # :user is the scope we are authenticating
      store_location_for(:user, request.fullpath)
    end

    def is_storable?
      true
    end
  end
  
  # include the extension
  ActionController::Base.send(:include, ThecoreUiRailsAdminConcern)
  