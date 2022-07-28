Rails.application.routes.draw do
  devise_for :customers
  root "mappings#index"

  resources :webhook_events, only: [:create, :index] do
    member do
      put :reprocess
    end
  end

  resource :customer, only: [:show, :update] do
    member do
      post :revoke_token
      get :ping_api
      get :wizard
    end
  end

  resources :mappings, only: [:index]
  resources :nocrm_steps, module: :mappings
  resources :nocrm_field_types, module: :mappings

  # oauth section for salesforce
  namespace :auth do
    resource :salesforce, controller: :salesforce, only: [:show] do
      collection do
        post :synchronize_fields
        post :revoke_token
      end
    end
    resources :salesforce, only: [] do
      collection do
        get :connect
        get :oauth2callback
        get :authentication
      end
    end
  end
end
