if Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_back_session', expire_after: 1.weeks, domain: 'twitch-back-885f64c14cf8.herokuapp.com'
else
  Rails.application.config.session_store :cookie_store, key: '_back_session', expire_after: 1.weeks, domain: 'localhost'
end