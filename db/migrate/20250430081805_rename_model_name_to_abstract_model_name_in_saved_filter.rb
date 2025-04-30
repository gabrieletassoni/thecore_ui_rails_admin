class RenameModelNameToAbstractModelNameInSavedFilter < ActiveRecord::Migration[7.2]
  def change
    rename_column :saved_filters, :model_name, :abstract_model_name
    # ThecoreUiRailsAdmin::SavedFilter.reset_column_information
    # ThecoreUiRailsAdmin::SavedFilter.all.each do |saved_filter|
    #   saved_filter.update_column(:abstract_model_name, saved_filter.model_name)
    # end
  rescue ActiveRecord::StatementInvalid => e
    puts "Error: #{e.message}"
  ensure
    # ThecoreUiRailsAdmin::SavedFilter.reset_column_information
  end
end
