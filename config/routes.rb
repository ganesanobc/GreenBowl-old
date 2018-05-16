Rails.application.routes.draw do
  resources :restaurants
  resources :kitchens
  resources :categories
  resources :products
  resources :orders do
    member do
      get :send_to_kitchen
    end
  end
  resources :order_items
  devise_for :admins, path: 'admins'
  devise_for :customers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
