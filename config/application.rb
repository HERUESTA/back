require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

# Load environment variables from .env file
if Rails.env.development? || Rails.env.test?
  Dotenv::Rails.load
end

module App
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    # デフォルトのロケールを日本語に設定
    config.i18n.default_locale = :ja
    # 使用可能なロケールを指定
    config.i18n.available_locales = [:en, :ja]
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_back_session'
    config.action_dispatch.cookies_same_site_protection = :none
    config.action_controller.forgery_protection_origin_check = false;
  end
end