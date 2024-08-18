require 'omniauth'
require 'omniauth/rails_csrf_protection'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitch, ENV['TWITCH_CLIENT_ID'], ENV['TWITCH_CLIENT_SECRET'], scope: 'user:read:email'
end