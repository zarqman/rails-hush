Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'good' => 'home#good'
  get 'ratelimited' => 'home#ratelimited'
  resources :resources
  resources :csrf_resources

end
