Rails.application.configure do
  config.action_cable.allowed_request_origins = [/.*/] # restrict to your staging server's domain + domains where you allow the widget to be embedded

  config.eager_load = true
end
