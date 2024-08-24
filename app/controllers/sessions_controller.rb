class SessionsController < ApplicationController
  

  def twitch
    state = SecureRandom.hex(24)
    session[:twitch_state] = state
    Rails.logger.debug "Session state set: #{session[:twitch_state]}"

    client_id = ENV['TWITCH_CLIENT_ID']
    redirect_uri = CGI.escape("#{request.base_url}/auth/twitch/callback")
    scope = CGI.escape('user:read:email')

    oauth_url = "https://id.twitch.tv/oauth2/authorize?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{scope}&state=#{session[:twitch_state]}"
    Rails.logger.debug "OAuth URL generated: #{oauth_url}"
    Rails.logger.debug "OAuth URL generated: #{redirect_uri}"
    Rails.logger.debug "=== State parameter from Twitch: #{params[:state]} ==="
    Rails.logger.debug "Session state set: #{session[:twitch_state]}"

    redirect_to oauth_url, allow_other_host: true
  end

  def callback
    Rails.logger.debug "=== Callback initiated with params: #{params} ==="
    Rails.logger.debug "=== Session state at callback: #{session[:twitch_state]} ==="
    Rails.logger.debug "=== State parameter from Twitch: #{params[:state]} ==="
    Rails.logger.debug "code : #{params[:code]}"

    if params[:state] != session[:twitch_state]
      Rails.logger.error "=== State parameter mismatch: expected #{session[:twitch_state]}, got #{params[:state]} ==="
      redirect_to root_path
      return
    end
    
    Rails.logger.debug "=== Sending request to Twitch for access token ==="
    Rails.logger.debug "code : #{params[:code]}"
    response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
      req.body = {
        client_id: ENV['TWITCH_CLIENT_ID'],
        client_secret: ENV['TWITCH_CLIENT_SECRET'],
        code: params[:code],
        grant_type: 'authorization_code',
        redirect_uri: "#{request.base_url}/auth/twitch/callback"
      }
      Rails.logger.debug "code : #{params[:code]}"
      
    end

    if response.status != 200
      Rails.logger.error "=== Failed to retrieve access token: #{response.body} ==="
      redirect_to root_path
      return
    end

    token_data = JSON.parse(response.body)
    access_token = token_data['access_token']

    Rails.logger.debug "=== Access Token retrieved: #{access_token} ==="

    user_info_response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
    end

    if user_info_response.status != 200
      Rails.logger.error "=== Failed to retrieve user info: #{user_info_response.body} ==="
      redirect_to root_path
      return
    end

    user_info = JSON.parse(user_info_response.body)['data'].first
    Rails.logger.debug "=== User information retrieved: #{user_info} ==="

    user = User.find_or_initialize_by(uid: user_info['id'])
    user.name = user_info['display_name']
    user.token = access_token
    user.refresh_token = token_data['refresh_token']
    user.expires_at = Time.now + token_data['expires_in'].to_i.seconds

    if user.save
      Rails.logger.debug "=== User #{user.name} was successfully saved. ==="
      session[:user_id] = user.id
      redirect_to "#{ENV['NEXT_PUBLIC_REDIRECT_AFTER_LOGIN_URL']}", notice: "ログインに成功しました"
    else
      Rails.logger.error "=== Failed to save user: #{user.errors.full_messages.join(', ')} ==="
      redirect_to root_path, alert: "ユーザー情報の保存に失敗しました。"
    end
  end
end