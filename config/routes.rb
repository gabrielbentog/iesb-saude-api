Rails.application.routes.draw do
  resources :time_slot_exceptions
  mount_devise_token_auth_for 'User', at: 'auth'
  post "login" => "authentication#login"

  get "up" => "rails/health#show", as: :rails_health_check
  
  namespace :api do
    get "calendar" => "calendar#calendar"
    resources :users
    resources :specialties, only: [] do
      collection do
        get "simple"
      end
    end

    resources :college_locations do
      resources :specialties
      resources :consultation_rooms
    end
    resources :time_slots
    resources :time_slot_exceptions
    resources :appointments
  end
end
