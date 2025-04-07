Rails.application.routes.draw do
  resources :specialties
  mount_devise_token_auth_for 'User', at: 'auth'
  post "login" => "authentication#login"

  get "up" => "rails/health#show", as: :rails_health_check
  
  namespace :api do
    resources :users
    resources :college_locations
  end
end
