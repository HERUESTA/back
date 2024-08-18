# config/routes.rb
Rails.application.routes.draw do
  root 'twitch#index'
  # Twitchの認証ルート
  get '/auth/twitch', to: 'sessions#new'
  get '/auth/twitch/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  delete '/logout', to: 'sessions#destroy'

  get '/twitch/clips', to: 'twitch#clips_by_game' 
  get '/twitch/:id', to: 'twitch#show'             
end