class User < ApplicationRecord
  # Minimal Devise setup -- just enough for thecore_ui_commons's
  # `devise_for :users` route mapping to find a configured `devise` method;
  # this dummy app never actually exercises authentication.
  devise :database_authenticatable

  has_many :push_subscribers, dependent: :destroy
end
