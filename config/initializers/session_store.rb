if Rails.env.production?
  Rails.application.config.session_store :cookie_store, 
    key: '_back_session', 
    expire_after: 1.week, 
    domain: '.example.com',  # ルートドメインを指定
    secure: true,     
    same_site: :none
else
  Rails.application.config.session_store :cookie_store, 
    key: '_back_session', 
    expire_after: 1.week, 
    domain: 'localhost'
end