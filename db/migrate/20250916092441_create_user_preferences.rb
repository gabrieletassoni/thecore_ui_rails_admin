class CreateUserPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.jsonb :value

      t.timestamps
    end
    add_index :user_preferences, :name
  end
end
