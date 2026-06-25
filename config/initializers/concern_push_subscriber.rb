require 'active_support/concern'

module ThecoreUiRailsAdminPushSubscriberConcern
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label 'Push Notifications'
      navigation_icon 'fa fa-bell'

      configure :created_at do
        hide
      end
      configure :updated_at do
        hide
      end
      configure :p256dh do
        hide
      end
      configure :auth do
        hide
      end
    end
  end
end
