class User < ApplicationRecord

  has_many :liked_videos, foreign_key: :uid, primary_key: :uid, dependent: :destroy  # いいねした動画との関連

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:twitch]
  

         def self.from_omniauth(auth)
          where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.email = auth.info.email
            user.password = Devise.friendly_token[0, 20]
            user.name = auth.info.name   # 追加の情報を設定する場合
            user.profile_image_url = auth.info.image # 例えばプロフィール画像
          end
        end
end
