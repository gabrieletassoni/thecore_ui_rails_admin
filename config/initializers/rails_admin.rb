require 'rails_admin'
require 'nested_form/builder_mixin'

RailsAdmin.config do |config|
  # Freeze more or fewer columns (col 1 = checkboxes, 2 = links/actions) for horizontal scrolling:
  config.sidescroll = {num_frozen_columns: 2}

  config.main_app_name = Proc.new { |controller| [ ((ENV["APP_NAME"].presence || Settings.app_name.presence) rescue "Thecore"), "" ] }
  # Link for background Job
  (config.navigation_static_links ||= {}).merge! "Background Monitor" => "#{ENV["BACKEND_URL"].presence || "http://localhost:3000"}/sidekiq"

  ### Popular gems integration
  config.model "RoleUser" do
    visible false
  end

  config.model "Predicate" do
    visible false
  end

  config.model "Target" do
    visible false
  end

  config.model "Action" do
    visible false
  end

  config.model "PermissionRole" do
    visible false
  end

  config.model "Permission" do
    visible false
  end

  config.model "ActionText::RichText" do
    visible false
  end

  config.model "ActiveStorage::Blob" do
    visible false
  end

  config.model "ActiveStorage::Attachment" do
    visible false
  end
  
  config.model "ActiveStorage::VariantRecord" do
      visible false
  end

  # action_mailbox~inbound_email
  config.model "ActionMailbox::InboundEmail" do
    visible false
  end
  
  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)
  
  ## == Cancan ==
  config.authorize_with :cancancan
  
  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  config.show_gravatar = false
  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
  config.label_methods.unshift(:display_name)
  
  config.actions do
    # show_in_app
    dashboard do
      show_in_sidebar true
    end# mandatory
    index # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    toggle
  end
end

# require "thecore_rails_admin_main_controller_concern"
