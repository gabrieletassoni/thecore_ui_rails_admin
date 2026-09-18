Rails.application.config.assets.precompile += %w(
    channels/index.js
)

Rails.application.config.assets.precompile += %w( rails_admin/actions/general_computation.js rails_admin/actions/general_computation.css )

Rails.application.config.assets.precompile += %w( rails_admin/actions/save_filters.js rails_admin/actions/save_filters.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/load_filters.js rails_admin/actions/load_filters.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/active_job_monitor.js rails_admin/actions/active_job_monitor.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/push_notification_test.js rails_admin/actions/push_notification_test.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/change_password.js rails_admin/actions/change_password.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/test_ldap_server.js rails_admin/actions/test_ldap_server.css )
Rails.application.config.assets.precompile += %w( rails_admin/actions/import_users_from_ldap.js rails_admin/actions/import_users_from_ldap.css )