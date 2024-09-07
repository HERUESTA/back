class SessionsController < ApplicationController
  before_action :set_twitch_client_details, only: [:twitch]

  def twitch
    state = SecureRandom.hex(24)
    session[:twitch_state] = state
    Rails.logger.debug "Redirect URI: #{@redirect_uri}" # デバッグ用ログ

    oauth_url = build_twitch_oauth_url(state)
    redirect_to oauth_url, allow_other_host: true
  end

  def callback   
    if params[:state] != session[:twitch_state]
      Rails.logger.error "Invalid state parameter"
      return render_error("無効な認証状態です。", :unprocessable_entity)
    end
    Rails.logger.debug "Twitch OAuth callback received with code: #{params[:code]}" # デバッグ用ログ
    
    token_data = fetch_access_token(params[:code])
    if token_data.nil?
      Rails.logger.error "アクセストークンの取得に失敗しました" # エラーログ
      return render_error("アクセストークンの取得に失敗しました。", :unprocessable_entity) unless token_data
    end

    Rails.logger.debug "Access Token Data' #{token_data}" # トークンデータのデバッグ用ログ

    user_info = fetch_user_info(token_data['access_token'])
    if user_info.nil?
      Rails.logger.error "ユーザー情報の取得に失敗しました" # エラーロ
      return render_error("ユーザー情報の取得に失敗しました。", :unprocessable_entity) unless user_info
    end

    Rails.logger.debug "User Info: #{user_info}" # ユーザー情報のデバッグ用ログ

    user = find_or_create_user(user_info, token_data)
    if user.save
      Rails.logger.debug "User saved successfully: #{user.inspect}" # ユーザーが保存された場合のデバッグ用ログ
      sign_in_and_redirect(user)
    else
      log_and_render_save_error(user)
    end
  end

  # フォローリストを取得するためのアクション
  def follows
    if current_user
      Rails.logger.debug "Current user: #{current_user.inspect}" # 現在のユーザー情報のデバッグ用ログ
      follows = fetch_user_follows(current_user.token, current_user.uid)
      Rails.logger.debug "Fetched Follows: #{follows}" # フォローリスト取得のデバッグ用ログ
      render json: follows.map { |follow| { displayName: follow['broadcaster_name'], profileImageUrl: follow['profile_image_url'] } }
    else
      Rails.logger.warn "Unauthorized access to follows action" # 認証されていないアクセスの警告ログ
      render json: { error: 'ユーザーがサインインしていません。' }, status: :unauthorized
    end
  end

  def destroy
    if current_user
      Rails.logger.debug "User signed out: #{current_user.inspect}"
      sign_out(current_user)
    else
      Rails.logger.warn "No user signed in"
    end
    reset_session
    head :no_content
  end

  private

  def set_twitch_client_details
    @client_id = ENV.fetch('TWITCH_CLIENT_ID') 
    @redirect_uri = ENV['REDIRECT_URI']
    @scope = CGI.escape('user:read:email user:read:follows')
  end

  def build_twitch_oauth_url(state)
    "https://id.twitch.tv/oauth2/authorize?client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&response_type=code&scope=#{@scope}&state=#{state}"
  end

  def fetch_access_token(code)
    response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
      req.body = {
        client_id: ENV['TWITCH_CLIENT_ID'],
        client_secret: ENV['TWITCH_CLIENT_SECRET'],
        code: code,
        grant_type: 'authorization_code',
        redirect_uri: "#{request.base_url}/auth/twitch/callback"
      }
    end 
    JSON.parse(response.body) if response.status == 200
  end

  def fetch_user_info(access_token)
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Client-ID'] = ENV['TWITCH_CLIENT_ID']
    end
    JSON.parse(response.body)['data'].first if response.status == 200
  end

  # フォローしているストリームの情報を取得
  def fetch_user_follows(access_token, user_id)
    response = Faraday.get("https://api.twitch.tv/helix/channels/followed") do |req|
      req.params['user_id'] = user_id
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Client-ID'] = ENV['TWITCH_CLIENT_ID']
    end

    if response.status == 200
      follows = JSON.parse(response.body)['data']
      user_ids = follows.map { |follow| follow['broadcaster_id'] }

      # プロフィール画像を取得するために追加のAPIコールを実行
      users_info = fetch_users_info(access_token, user_ids) # ユーザー情報を取得するメソッドを追加で呼び出し
      follows.map do |follow|
        user_info = users_info.find { |user| user['id'] == follow['broadcaster_id'] }
        {
          'broadcaster_name' => follow['broadcaster_name'],
          'profile_image_url' => user_info ? user_info['profile_image_url'] : nil
        }
      end
    else
      Rails.logger.error "Failed to fetch follows: #{response.body}"
      []
    end
  end

  # 複数のユーザー情報を取得するメソッド
  def fetch_users_info(access_token, user_ids)
    response = Faraday.get("https://api.twitch.tv/helix/users") do |req|
      req.params['id'] = user_ids
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Client-ID'] = ENV['TWITCH_CLIENT_ID']
    end
    JSON.parse(response.body)['data'] if response.status == 200
  end

  def find_or_create_user(user_info, token_data)
    User.find_or_initialize_by(uid: user_info['id']).tap do |user|
      user.assign_attributes(
        name: user_info['display_name'],
        email: user_info['email'],
        token: token_data['access_token'],
        refresh_token: token_data['refresh_token'],
        expires_at: Time.now + token_data['expires_in'].to_i.seconds,
        profile_image_url: user_info['profile_image_url'],
        password: Devise.friendly_token[0, 20]
      )

      # フォローリストを取得
      follows = fetch_user_follows(token_data['access_token'], user_info['id'])
      Rails.logger.debug "フォローリスト: #{follows}" # フォロー情報のデバッグログ

      # フォローリストが存在する場合に保存
      if follows.any?
        Rails.logger.debug "保存フォローリスト: #{follows.inspect}" # フォロー情報のデバッグログ
        user.followed_streamers = follows.map { |follow| follow['broadcaster_name'] }.join(", ")
      end
    end
  end

  def sign_in_and_redirect(user)
    sign_in(user)
    session[:user_id] = user.id
    Rails.logger.debug "User signed in and session set for user_id: #{user.id}" # ユーザーのサインインのデバッグ用ログ
    redirect_to ENV['NEXT_PUBLIC_REDIRECT_AFTER_LOGIN_URL'], allow_other_host: true
  end

  def log_and_render_save_error(user)
    Rails.logger.error "=== Failed to save user: #{user.errors.full_messages.join(', ')} ==="
    render json: { error: "ユーザー情報の保存に失敗しました。" }, status: :unprocessable_entity
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end