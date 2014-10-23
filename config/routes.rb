Rails.application.routes.draw do
  root 'welcome#index'
  devise_for :users

  namespace :admin do
    root 'items#index'
    resources :pages, except: :show
    resources :items, except: :show
  end

  resources :items, only: [:index, :show]
  resources :pages, only: :show
end
