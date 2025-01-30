Rails.application.routes.draw do
  mount RailsAdmin::Engine => "#{ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/')}/app".gsub('//', '/'), as: 'rails_admin'
end