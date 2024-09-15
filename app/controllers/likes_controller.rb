# app/controllers/likes_controller.rb
class LikesController < ApplicationController
  before_action :authenticate_user!

  # いいねした動画を保存
  def create
    liked_video = current_user.liked_videos.new(liked_video_params)

    if liked_video.save
      render json: { success: true, liked_video: liked_video }, status: :created
    else
      render json: { success: false, errors: liked_video.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # いいねした動画一覧を取得
  def index
    liked_videos = current_user.liked_videos
    render json: liked_videos
  end

  # いいねした動画を削除
  def destroy
    liked_video = current_user.liked_videos.find_by(video_id: params[:id])
    
    if liked_video&.destroy
      render json: { success: true }, status: :ok
    else
      render json: { success: false, errors: ['動画が見つかりません'] }, status: :unprocessable_entity
    end
  end


  private

  def liked_video_params
    params.require(:liked_video).permit(:video_id, :title, :thumbnail_url, :video_url)
  end
end