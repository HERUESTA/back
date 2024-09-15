class LikedVideo < ApplicationRecord
  belongs_to :user, foreign_key: :uid, primary_key: :uid  # Userモデルとの関連をuidで定義

  validates :uid, :video_id, presence: true  # 必須項目
  validates :video_id, uniqueness: { scope: :uid }  # 同じユーザーが同じ動画を複数回保存できないようにする
end