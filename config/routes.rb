Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  post "login" => "authentication#login"

  get "up" => "rails/health#show", as: :rails_health_check
  
  resources :users
end
