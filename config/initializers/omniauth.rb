Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitch, ENV['TWITCH_CLIENT_ID'], ENV['TWITCH_CLIENT_SECRET'], {
    scope: 'user:read:email',
    redirect_uri: "#{ENV['REDIRECT_URI']}/auth/twitch/callback",
    provider_ignores_state: false
  }
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.silence_get_warning = true

# CSRFトークンの整合性を確認するための設定
OmniAuth.config.before_request_phase do |env|
  session = env['rack.session']
  Rails.logger.debug "オムニ: #{session}"
  session[:omniauth_csrf_token] = SecureRandom.hex(24)
  env['omniauth.strategy'].options[:state] = session[:omniauth_csrf_token]
end

OmniAuth.config.before_callback_phase do |env|
  session = env['rack.session']
  request_state = env['omniauth.strategy'].request.params['state']
  if session[:omniauth_csrf_token] != request_state
    raise OmniAuth::Strategies::OAuth2::CallbackError.new(:csrf_detected, "CSRF detected")
  end
end