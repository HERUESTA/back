Rails.application.routes.draw do
  get 'twitch/:id', to: 'twitch#index'
end
