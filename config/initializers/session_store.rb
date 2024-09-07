if Rails.env.production?
  Rails.application.config.session_store :cookie_store, 
    key: '_back_session', 
    expire_after: 1.week, 
    domain: :all,  # 全サブドメインで適用する場合
    secure: true,     
    same_site: :none
else
  Rails.application.config.session_store :cookie_store, 
    key: '_back_session', 
    expire_after: 1.week, 
    domain: 'localhost'
end