Rails.application.config.assets.precompile += %w(
    channels/index.js
)

Rails.application.config.assets.precompile += %w( rails_admin/actions/general_computation.js rails_admin/actions/general_computation.css )

Rails.application.config.assets.precompile += %w( rails_admin/actions/save_filters.js rails_admin/actions/save_filters.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/load_filters.js rails_admin/actions/load_filters.css )