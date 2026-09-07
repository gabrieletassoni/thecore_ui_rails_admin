class User < ApplicationRecord
  # Minimal Devise setup -- just enough for thecore_ui_commons's
  # `devise_for :users` route mapping to find a configured `devise` method,
  # and (with :validatable) to exercise real password-confirmation/length
  # validation errors for the change_password member action's tests below.
  devise :database_authenticatable, :validatable

  has_many :push_subscribers, dependent: :destroy

  # `ThecoreAuthCommonsCanCanCanConcern#initialize` unconditionally runs
  # `Permission.joins(roles: :users)` -- these associations give it
  # somewhere to join to (the tables stay empty in tests), mirroring
  # thecore_auth_commons's own real User model.
  has_many :role_users, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :role_users, inverse_of: :users
end
