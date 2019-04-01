require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MonitoringWebService
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = [:ru]
    config.i18n.default_locale = :ru
    config.i18n.fallbacks = [I18n.default_locale]

    # config.autoload_paths += Dir[Rails.root.join('lib')]
    config.autoload_paths += [Rails.root.join('lib').to_s]
    
    # custom configs
    config.app    = config_for :application
    config.admins = {emails: ENV['ADMIN_EMAILS'].split(';').map(&:strip)}
    config.redis  = config_for :redis
    config.specs  = config_for :specs
  end
end
