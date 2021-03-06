Rails.application.routes.draw do
    mount RailsAdmin::Engine => '/app', as: 'rails_admin'
    
    get "home", to: "pages#home", as: "home"
    get "inside", to: "pages#inside", as: "inside"
    get "/contact", to: "pages#contact", as: "contact"
    post "/emailconfirmation", to: "pages#email", as: "email_confirmation"
    
    devise_scope :user do
        root to: "devise/sessions#new"
    end
end
