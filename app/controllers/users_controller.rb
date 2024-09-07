class UsersController < ApplicationController
  include Devise::Controllers::Helpers
  before_action :authenticate_user!, only: [:profile]

  def profile
    # セッションデータのデバッグログ
    Rails.logger.debug "Session data at profile: #{session.to_hash}" 

    # セッション情報が存在するか確認
    if session[:user_id].nil?
      Rails.logger.warn "No user session found. Redirecting to sign in."
      return render json: { error: 'セッションが見つかりません。サインインしてください。' }, status: :unauthorized
    end

    # current_userが存在するかどうかチェック
    unless current_user
      Rails.logger.warn "Unauthorized access attempt detected" 
      return render json: { error: 'ユーザーがサインインしていません。' }, status: :unauthorized
    end
    
    user = current_user # 現在のログインユーザーを取得

    # トークン情報のデバッグ用ログ
    Rails.logger.debug "Access Token: #{user.token}"  
    Rails.logger.debug "Refresh Token: #{user.refresh_token}"
    Rails.logger.debug "Token Expiry: #{user.expires_at}"

    # プロフィール情報をJSON形式で返す
    render json: { profile_image_url: user.profile_image_url }
  end
end