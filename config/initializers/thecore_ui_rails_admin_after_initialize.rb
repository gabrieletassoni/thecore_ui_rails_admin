Rails.application.configure do
    config.after_initialize do
        # Freeze more or fewer columns (col 1 = checkboxes, 2 = links/actions) for horizontal scrolling:
        RailsAdmin::Config.sidescroll = {num_frozen_columns: 2}

        RailsAdmin::Config.main_app_name = Proc.new { |controller| [ ((ENV["APP_NAME"].presence || Settings.app_name.presence) rescue "Thecore"), "" ] }
        # Link for background Job
        # (config.navigation_static_links ||= {}).merge! "Background Monitor" => "#{ENV["BACKEND_URL"].presence || "http://localhost:3000"}/sidekiq"

        ### Popular gems integration
        ## == Devise ==
        RailsAdmin::Config.authenticate_with do
            warden.authenticate! scope: :user
        end
        RailsAdmin::Config.current_user_method(&:current_user)

        ## == Cancan ==
        RailsAdmin::Config.authorize_with :cancancan

        ## == PaperTrail ==
        # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
        RailsAdmin::Config.show_gravatar = false
        ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
        RailsAdmin::Config.label_methods.unshift(:display_name)

        RailsAdmin::Config::Actions.add_action "active_job_monitor", :base, :root do
            show_in_sidebar true
            show_in_navigation false
            breadcrumb_parent [nil]
            # This ensures the action only shows up for Users
            # visible? authorized?
            # Not a member action
            member false
            # Not a colleciton action
            collection false
            
            link_icon 'fas fa-eye'
            
            # You may or may not want pjax for your action
            # pjax? true
            
            http_methods [:get]
            # Adding the controller which is needed to compute calls from the ui
            controller do
                proc do # This is needed because we need that this code is re-evaluated each time is called
                    puts "Loading Active Job Monitor Controller"
                end
            end
        end

        # include the extension
        ActionController::Base.send(:include, ThecoreUiRailsAdminActionControllerConcern)
        RailsAdmin::Config::Actions::Export.send(:include, ExportConcern)
        RailsAdmin::Config::Actions::BulkDelete.send(:include, BulkDeleteConcern)
        Role.send :include, ThecoreUiRailsAdminRoleConcern
        UsedToken.send :include, ThecoreUiRailsAdminInvisiblesConcern rescue puts "No UsedToken Model it could be normal: maybe model_driven_api is not installed"
        User.send :include, ThecoreUiRailsAdminUserConcern
        ThecoreSettings::Setting.send :include, ThecoreUiRailsAdminSettingsConcern

        RoleUser.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Predicate.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Target.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Action.send :include, ThecoreUiRailsAdminInvisiblesConcern
        PermissionRole.send :include, ThecoreUiRailsAdminInvisiblesConcern
        Permission.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActionText::EncryptedRichText.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActionText::RichText.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActiveStorage::Blob.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActiveStorage::Attachment.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActiveStorage::VariantRecord.send :include, ThecoreUiRailsAdminInvisiblesConcern
        ActionMailbox::InboundEmail.send :include, ThecoreUiRailsAdminInvisiblesConcern
    end
end