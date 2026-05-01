# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # OmniAuth
  # (The POST /auth/:provider request is handled by the OmniAuth middleware itself — no route needed)
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/sign_out", to: "sessions#destroy", as: :sign_out

  # Onboarding
  get "/onboarding", to: "onboarding#show", as: :onboarding
  post "/onboarding", to: "onboarding#create"
  get "/onboarding/hobbies", to: "onboarding#hobbies", as: :onboarding_hobbies

  # Hobbies
  resources :user_hobbies, only: [:create, :destroy]
  resources :hobbies, only: [:show]

  # Profiles
  resources :profiles, only: [:show], param: :username

  # Events + attendees
  resources :events, only: [] do
    resources :attendees, only: [:index]
  end

  # Authenticated
  get "/dashboard", to: "dashboard#index", as: :dashboard
end
