puts "Loading Sidekiq Monitor File"
require 'rails_admin/config/actions'

module RailsAdmin
	module Config
		module Actions
			class ThecoreSidekiqMonitor < Base
				RailsAdmin::Config::Actions.register(self)
				register_instance_option :object_level do
					false
				end
				# This ensures the action only shows up for Users
				register_instance_option :visible? do
					# visible only if authorized and if the object has a defined method
					authorized? #&& bindings[:abstract_model].model == ThecoreSpotItemsImporterXl && bindings[:abstract_model].model.column_names.include?('barcode')
				end
				# We want the action on members, not the Users collection
				register_instance_option :member do
					false
				end
				
				register_instance_option :collection do
					false
				end
				register_instance_option :root? do
					true
				end
				
				register_instance_option :breadcrumb_parent do
					[nil]
				end
				
				register_instance_option :link_icon do
					'fa fa-caret-square-o-right'
				end

				register_instance_option :show_in_sidebar do
					true
				end
				
				# You may or may not want pjax for your action
				register_instance_option :pjax? do
					true
				end
				
				register_instance_option :http_methods do
					[:get]
				end
				# Adding the controller which is needed to compute calls from the ui
				register_instance_option :controller do
					proc do # This is needed because we need that this code is re-evaluated each time is called
						
						puts "Loading Sidekiq Monitor Controller"
					end
				end
			end
		end
	end
end
