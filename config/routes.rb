Rails.application.routes.draw do
  root 'twitch#index'

  
  get '/auth/twitch', to: 'sessions#twitch'
  get '/auth/twitch/callback', to: 'sessions#callback'
  get '/auth/failure', to: redirect('/')
  delete '/logout', to: 'sessions#destroy'
  get '/twitch/clips', to: 'twitch#clips_by_game'
  get '/twitch/:id', to: 'twitch#show'

  # 他のルート設定
  get '/csrf_token', to: 'application#csrf_token'
end