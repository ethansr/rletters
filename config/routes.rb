RLetters::Application.routes.draw do
  # Search/Browse page
  get "search" => 'search#index'

  # Datasets (per-user)
  resources :datasets, :except => [:edit, :update, :new]

  # Custom login built around Janrain Engage
  get 'users' => 'users#index'
  post 'users' => 'users#create'
  get 'users/rpx'
  get 'users/logout'

  # Static information pages
  get 'info' => 'info#index'
  get 'info/privacy'

  # FIXME
  root :to => 'mockup#index'

  # FIXME
  match ':controller(/:action(/:id(.:format)))'
end
