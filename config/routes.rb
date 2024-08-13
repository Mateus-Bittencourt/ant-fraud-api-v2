require 'sidekiq/web'

Rails.application.routes.draw do
  resources :transactions, only: [:create] do
    collection do
      post :register_chargeback
    end
  end
  mount Sidekiq::Web => '/sidekiq'
end
