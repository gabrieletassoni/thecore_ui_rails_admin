LARGE_SUBSCRIBER_THRESHOLD = 10

RailsAdmin::Config::Actions.add_action "push_notification_test", :base, :root do
  show_in_sidebar true
  show_in_navigation false
  breadcrumb_parent [nil]

  member false
  collection false

  link_icon "fas fa-bell"

  http_methods [:get, :post]

  controller do
    proc do
      @large_subscriber_threshold = LARGE_SUBSCRIBER_THRESHOLD
      @total_count = PushSubscriber.active.count
      @subscriber_emails = User.joins(:push_subscribers).merge(PushSubscriber.active).distinct.pluck(:email)

      filter_query = params[:q].presence
      @subscribers = if filter_query
        PushSubscriber.active.includes(:user).joins(:user).where("users.email ILIKE ?", "%#{filter_query}%")
      else
        []
      end

      if request.post?
        params.permit!
        title = params[:title].to_s.strip
        body  = params[:body].to_s.strip

        if title.blank?
          flash.now[:error] = I18n.t(
            "admin.actions.push_notification_test.error_blank_title",
            default: "Title can't be blank"
          )
          render action: :push_notification_test, status: :unprocessable_entity
        else
          subscriber_ids = Array(params[:subscriber_ids]).map(&:to_i).select(&:positive?)
          subscribers    = PushSubscriber.where(id: subscriber_ids)

          subscribers.each do |subscriber|
            message = PushMessage.create!(
              push_subscriber: subscriber,
              title: title,
              body: body,
              url: params[:url].presence,
              icon: params[:icon].presence
            )
            ThecoreBackendCommons::PushNotificationService.dispatch(subscriber, message)
          end

          flash[:success] = I18n.t(
            "admin.actions.push_notification_test.success",
            count: subscribers.size,
            default: "Sent test notification to %{count} subscriber(s)"
          )
          redirect_to push_notification_test_path
        end
      end
    end
  end
end
