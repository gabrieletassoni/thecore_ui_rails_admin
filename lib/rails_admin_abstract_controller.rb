class RailsAdminAbstractController < ActionController::Base
  before_action :set_locale
  
  private

  def set_locale
    I18n.locale = current_user.locale if current_user
  end
end