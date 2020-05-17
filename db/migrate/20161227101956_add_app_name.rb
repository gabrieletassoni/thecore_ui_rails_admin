class AddAppName < ActiveRecord::Migration[5.0]  
  def change
    Settings.app_name = "The Core by Gabriele Tassoni"
  end
end
