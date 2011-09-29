# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do

  scope "(:locale)", :locale => /[a-z]{2,3}(-[A-Z]{2})?/ do
    # Search/Browse page
    match "search" => 'search#index'

    # Datasets (per-user)
    resources :datasets, :except => [:edit, :update, :new]

    # Custom login built around Janrain Engage
    match 'users' => 'users#index', :via => :get
    match 'users' => 'users#create', :via => :post
    match 'users/rpx' => 'users#rpx'
    match 'users/update' => 'users#update'
    match 'users/logout' => 'users#logout'

    # Static information pages
    match 'info' => 'info#index'
    match 'info/privacy' => 'info#privacy'
  end

  # Localized root routes (root/es)
  match '/:locale' => 'search#index', :constraints => { :locale => /[a-z]{2,3}(-[A-Z]{2})?/ }

  # Start off on the search page (it's the part you can
  # do without being logged in)
  root :to => 'search#index'
end
