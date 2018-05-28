Rails.application.routes.draw do
  resources :restaurants
  resources :kitchens
  resources :categories
  resources :products
  resources :orders do
    member do
      get :send_to_kitchen
      get :pay
    end
  end
  resources :order_items do
    member do
      get :accept
      get :reject
      get :prepared
    end
  end
  devise_for :admins, path: 'admins'
  devise_for :customers

  root to: "orders#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
