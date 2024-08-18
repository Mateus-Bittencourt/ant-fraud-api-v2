require 'sidekiq/web'

Rails.application.routes.draw do
  resources :transactions, only: [:create] do
    collection do
      patch :register_chargeback
    end
  end
  post 'auth/login', to: 'authentication#login'

  mount Sidekiq::Web => '/sidekiq'
end
