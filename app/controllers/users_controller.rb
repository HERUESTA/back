class UsersController < ApplicationController
  include Devise::Controllers::Helpers
  before_action :authenticate_user!

  def profile
    user = current_user # 現在のログインユーザーを取得
    
    # トークン情報のデバッグ用ログ
    Rails.logger.debug "Access Token: #{user.token}" 
    Rails.logger.debug "Refresh Token: #{user.refresh_token}"
    Rails.logger.debug "Token Expiry: #{user.expires_at}"

    # プロフィール情報をJSON形式で返す
    render json: { profile_image_url: user.profile_image_url }
  end
end