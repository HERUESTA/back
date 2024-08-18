Rails.application.routes.draw do
  root 'twitch#index'
  
  # Login route to initiate Twitch authentication
  get '/login', to: 'sessions#new'
  s
  # Callback route for Twitch authentication
  get '/auth/twitch/callback', to: 'sessions#create'
  
  # Route for handling authentication failures
  get '/auth/failure', to: redirect('/')
  
  # Logout route
  delete '/logout', to: 'sessions#destroy'
  
  # Routes for Twitch clips and videos
  get '/twitch/clips', to: 'twitch#clips_by_game' 
  get '/twitch/:id', to: 'twitch#show'
end