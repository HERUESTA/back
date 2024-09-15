class CreateLikedVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :liked_videos do |t|
      t.string :uid, null: false  # Usersテーブルのuidに対応
      t.string :video_id, null: false  # Twitchの動画ID
      t.string :title  # 動画のタイトル
      t.string :thumbnail_url  # 動画のサムネイルURL
      t.string :video_url  # 動画の埋め込みURL
      t.timestamps
    end

    # uidとvideo_idの組み合わせを一意にする
    add_index :liked_videos, [:uid, :video_id], unique: true
  end
end