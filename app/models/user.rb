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
    
        def token_expired?
          expires_at <= Time.current
        end
      
        def refresh_access_token!
          response = Faraday.post("https://id.twitch.tv/oauth2/token") do |req|
            req.body = {
              grant_type: 'refresh_token',
              refresh_token: refresh_token,
              client_id: ENV['TWITCH_CLIENT_ID'],
              client_secret: ENV['TWITCH_CLIENT_SECRET']
            }
          end
      
          if response.status == 200
            new_token_data = JSON.parse(response.body)
            update(
              token: new_token_data['access_token'],
              refresh_token: new_token_data['refresh_token'],
              expires_at: Time.current + new_token_data['expires_in'].to_i.seconds
            )
            true
          else
            Rails.logger.error "Failed to refresh access token: #{response.body}"
            false
          end
        end
end
