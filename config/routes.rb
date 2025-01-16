Rails.application.routes.draw do
  scope ENV.fetch("RAILS_RELATIVE_URL_ROOT", "/") do
    mount RailsAdmin::Engine => '/app', as: 'rails_admin'
  end
end