# config/routes.rb
Rails.application.routes.draw do
  get '/twitch/:id', to: 'twitch#show'
end