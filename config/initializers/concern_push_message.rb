require 'active_support/concern'

module ThecoreUiRailsAdminPushMessageConcern
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label 'Push Notifications'
      navigation_icon 'fa fa-envelope'

      parent PushSubscriber

      configure :created_at do
        hide
      end
      configure :updated_at do
        hide
      end
    end
  end
end
