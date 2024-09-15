if Rails.env.production?
  Rails.application.config.session_store :cookie_store, 
    key: '_back_session', 
    expire_after: 1.week, 
    domain: 'twitch-back-885f64c14cf8.herokuapp.com',  # バックエンドの正確なドメインを指定
    secure: true,     
    same_site: :none
else
  Rails.application.config.session_store :cookie_store, 
    key: '_back_session', 
    expire_after: 1.week, 
    domain: 'localhost'
end