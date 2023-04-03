Rails.application.config.assets.precompile += %w(
    channels/index.js
    channels/consumer.js
    channels/activity_log_channel.js
)
