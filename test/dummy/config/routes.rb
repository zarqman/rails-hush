Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'good' => 'home#good'
  resources :resources
  resources :csrf_resources

end
