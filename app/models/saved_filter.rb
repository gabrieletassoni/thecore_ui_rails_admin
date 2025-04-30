# app/models/saved_filter.rb
class SavedFilter < ApplicationRecord
  belongs_to :admin_user, optional:true, class_name: 'User', foreign_key: :admin_user_id

  validates :model_name, :name, :query_string, presence: true

  rails_admin do
    # Set invisible
    visible false
  end
end
