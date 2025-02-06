class AddLocaleToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :locale, :string, default: I18n.default_locale.to_s
    add_index :users, :locale
  end
end
