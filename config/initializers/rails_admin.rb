require 'rails_admin'
require 'nested_form/builder_mixin'

RailsAdmin.config do |config|
  # Link for background Job
  (config.navigation_static_links ||= {}).merge! "Background Monitor" => "#{ENV['RAILS_RELATIVE_URL_ROOT']}/app/sidekiq"

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
    dashboard # mandatory
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
