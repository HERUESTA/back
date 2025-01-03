Rails.application.routes.draw do
  # Devise routes
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # Root route
  root 'twitch#index'

  # Twitch authentication routes
  get '/auth/twitch', to: 'sessions#twitch'
  get '/auth/twitch/callback', to: 'sessions#callback'
  get '/auth/failure', to: redirect('/')

  # Logout route
  delete '/logout', to: 'sessions#destroy'

  # Twitch routes
  get '/twitch/clips', to: 'twitch#clips_by_game'

  # 配信者名検索　
  namespace :search do
    get '/streamers/:id', to: 'streamers#show'
  end

  # User profile route
  get '/api/user_profile', to: 'users#profile' # ユーザーのプロファイル情報を取得するエンドポイント

  get '/api/follows', to: 'sessions#follows' # フォローリストを取得するエンドポイント

  # Likesコントローラのルーティング　変更
  resources :liked_videos, only: [:create, :index, :destroy], controller: 'likes'
end