class UsersController < ApplicationController
  include Devise::Controllers::Helpers
  before_action :authenticate_user!

  def profile
    user = current_user # 現在のログインユーザーを取得
    render json: { profile_image_url: user.profile_image_url } # JSON形式で返す
  end
end