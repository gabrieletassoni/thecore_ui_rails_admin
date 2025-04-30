# db/migrate/xxxx_create_saved_filters.rb
class CreateSavedFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_filters do |t|
      t.string :model_name
      t.string :name
      t.text :query_string
      t.references :admin_user, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
