require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FaqBotFramework
  class Application < Rails::Application

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib)

    config.time_zone = 'Europe/Paris'

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = config.log_formatter
      config.logger    = logger
    else
      rails_log_dir    = ENV["RAILS_LOG_DIR"] || "/home/LogFiles"
      FileUtils.mkdir_p rails_log_dir
      logfile          = File.join(rails_log_dir, "#{Rails.env}.log")
      logger           = ActiveSupport::Logger.new(logfile)
      logger.formatter = config.log_formatter
      config.logger    = logger
    end

    config.classifiers = config_for(:classifiers)
  end
end
