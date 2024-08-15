require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load environment variables from .env file
if Rails.env.development? || Rails.env.test?
  Dotenv::Railtie.load
end

module App
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja

    # CORS設定を追加
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:3000', 'front-pink-nine.vercel.app', 'twitch-back-885f64c14cf8.herokuapp.com'
        resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head]
      end
    end

    # CSP設定を追加
    config.action_dispatch.default_headers = {
      'Content-Security-Policy' => "frame-ancestors 'self' https://front-pink-nine.vercel.app https://twitch-back-885f64c14cf8.herokuapp.com"
    }
  end
end