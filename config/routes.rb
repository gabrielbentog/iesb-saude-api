Rails.application.routes.draw do
  resources :time_slot_exceptions
  get "up" => "rails/health#show", as: :rails_health_check
  
  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      passwords: 'api/auth/passwords'
    }
    post "password/code_verify" => "users#code_verify" 

    post "login" => "authentication#login"

    get "calendar" => "calendar#calendar"
    resources :users do
      collection do
        get :interns
        get :me
      end

      member do
        put :change_password
      end
    end

    resources :dashboard, only: [] do
      collection do
        get :kpis
        get :patient_kpis
      end
    end

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
    resources :appointments do
      resources :appointment_status_histories, only: [:index]

      collection do
        get :next
      end

      member do
        patch :confirm
        patch :cancel
        patch :reject
      end
    end
  end
end
