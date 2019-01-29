Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'games#index'

  resources :games

  resources :offensive_play_sets, only: :index
  resources :off_def_charts, only: :index
end
