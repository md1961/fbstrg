Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'leagues#index'

  resources :teams, only: :index

  resources :games, only: %i[index show update] do
    collection do
      get :replay
    end
  end

  resources :leagues, only: %i[index show]

  resources :schedules, only: %i[] do
    member do
      patch :postpone
    end
  end

  resources :team_traits, only: [] do
    member do
      get :increment, :decrement
    end
  end

  resources :stats, only: :index

  resources :play_sets, only: :index
  resources :off_def_charts, only: :index

  resources :miscs, only: :index
end
