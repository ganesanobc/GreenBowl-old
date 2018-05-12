Rails.application.routes.draw do
  resources :products
  resources :categories
  devise_for :admins, path: 'admins'
  devise_for :customers
  resources :kitchens
  resources :restaurants
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
