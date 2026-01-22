class RailsAdminAbstractController < ActionController::Base
  before_action :set_locale

  # Example: Catch foreign key violations or DB constraints
  rescue_from ActiveRecord::StatementInvalid, with: :handle_database_error

  # Example: Catch generic ActiveRecord errors
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid

  rescue_from ActiveRecord::RangeError, with: :handle_database_error

  private

  def handle_database_error(exception)
    # Check if this request is coming from Rails Admin
    # if request.path.start_with?(RailsAdmin::Engine.routes.find_script_name({}))
    # If it's a ActiveRecord::RangeError also suggest to use the specific filter on an attribute to explain how to fix
    if exception.is_a?(ActiveRecord::RangeError)
      flash[:error] = I18n.t(:active_record_range_error)
    else
      flash[:error] = "Database Error: #{exception.message}"
    end
    redirect_back(fallback_location: rails_admin.dashboard_path)
    # else
    #   # Fallback to default behavior for the rest of your app if you prefer
    #   raise exception
    # end
  end

  def handle_record_invalid(exception)
    # if request.path.start_with?(RailsAdmin::Engine.routes.find_script_name({}))
    flash[:error] = "Validation Error: #{exception.record.errors.full_messages.join(", ")}"
    redirect_back(fallback_location: rails_admin.dashboard_path)
    # else
    #   raise exception
    # end
  end

  def set_locale
    I18n.locale = current_user.locale if current_user
  end
end
