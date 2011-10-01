# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do
  # Search/Browse page
  match 'search' => 'search#index', :via => :get

  # Datasets (per-user)
  resources :datasets, :except => [:edit, :update, :new]

  # Custom login built around Janrain Engage
  match 'users' => 'users#index', :via => :get
  match 'users' => 'users#create', :via => :post
  match 'users/rpx' => 'users#rpx', :via => :post
  match 'users/new' => 'users#new'
  match 'users/update' => 'users#update', :via => :put
  match 'users/login' => 'users#login', :via => :get
  match 'users/logout' => 'users#logout', :via => :get

  # Static information pages
  match 'info' => 'info#index', :via => :get
  match 'info/privacy' => 'info#privacy', :via => :get

  # Start off on the search page (it's the part you can
  # do without being logged in)
  root :to => 'search#index'
end
