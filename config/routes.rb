Rails.application.routes.draw do
  mount RailsAdmin::Engine => "#{ENV.fetch('RAILS_RELATIVE_URL_ROOT', '')}/app", as: 'rails_admin'
end