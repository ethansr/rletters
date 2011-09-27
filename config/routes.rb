# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do
  # Search/Browse page
  get "search" => 'search#index'

  # Datasets (per-user)
  resources :datasets, :except => [:edit, :update, :new]

  # Custom login built around Janrain Engage
  get 'users' => 'users#index'
  post 'users' => 'users#create'
  post 'users/rpx'
  post 'users/update'
  get 'users/logout'

  # Static information pages
  get 'info' => 'info#index'
  get 'info/privacy'

  # Start off on the search page (it's the part you can
  # do without being logged in)
  root :to => 'search#index'
end
