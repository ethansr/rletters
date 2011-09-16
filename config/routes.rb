RLetters::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # Search/Browse page
  get "search" => 'search#index'

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
