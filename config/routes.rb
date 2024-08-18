Rails.application.routes.draw do
  root 'twitch#index'
  
  get '/auth/twitch', to: redirect('/auth/twitch')
  get '/auth/twitch/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  delete '/logout', to: 'sessions#destroy'
  get '/twitch/clips', to: 'twitch#clips_by_game'
  get '/twitch/:id', to: 'twitch#show'
end