class UsersController < ApplicationController
  include Devise::Controllers::Helpers
  before_action :authenticate_user!

  def profile
    Rails.logger.debug "Session data at profile: #{session.to_hash}" # セッションデータのデバッグログ
    Rails.logger.debug "Session in profile: #{session.inspect}" # プロフィール取得後のセッションの状態をデバッグログに記録
    unless current_user
      Rails.logger.warn "Unauthorized access attempt detected" # 認証されていないアクセスの警告ログ
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