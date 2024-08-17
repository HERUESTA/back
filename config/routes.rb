# config/routes.rb
Rails.application.routes.draw do
  get '/twitch/clips', to: 'twitch#clips_by_game'  # より具体的なルートを先に定義
  get '/twitch/:id', to: 'twitch#show'             # 汎用的なルートを後に定義
end