Rails.application.routes.draw do
    
    get "home", to: "pages#home", as: "home"
    get "inside", to: "pages#inside", as: "inside"
    get "/contact", to: "pages#contact", as: "contact"
    post "/emailconfirmation", to: "pages#email", as: "email_confirmation"
    
    devise_scope :user do
        root to: "devise/sessions#new"
    end

    # Allow any authenticated User with admin capability
    # authenticate :user, lambda { |u| u.admin? } do
    #     mount Blazer::Engine, at: "blazer"
    # end
end
