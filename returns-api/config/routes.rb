Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :merchants do
        resources :products
        resources :return_rules
      end
      resources :orders do
        collection do
          get :lookup
        end
      end
      resources :return_requests do
        collection do
          post :batch, action: :create_batch
        end
        member do
          patch :approve
          patch :reject
          patch :ship
          patch :mark_received
          patch :resolve
          get :audit_logs
        end
      end

      # Merchant Returns Dashboard
      get 'merchants/:merchant_id/returns', to: 'return_requests#by_merchant', as: :merchant_returns

      # Webhooks
      namespace :webhooks do
        post :carrier
      end
    end
  end
end
