class UserPreference < ApplicationRecord
  include Api::UserPreference
  include RailsAdmin::UserPreference
  belongs_to :user, inverse_of: :user_preferences
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :value, presence: true
end
