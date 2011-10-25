# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do
  # Search/Browse page
  match 'search' => 'search#index', :via => :get
  match 'search/advanced' => 'search#advanced', :via => :get
  match 'search/document/:id' => 'search#show', :via => :get, :as => 'search_show'
  match 'search/document/:id/mendeley' => 'search#to_mendeley', :via => :get, :as => 'mendeley_redirect'
  match 'search/document/:id/citeulike' => 'search#to_citeulike', :via => :get, :as => 'citeulike_redirect'

  # Datasets (per-user)
  resources :datasets, :except => [ :edit, :update ] do
    member do
      get 'delete'
    end
  end

  # Custom login built around Janrain Engage
  resource :user, :except => [ :destroy, :edit ] do
    member do
      post 'rpx'
      get 'login'
      get 'logout'
    end
    
    resources :libraries, :except => :show do
      member do
        get 'delete'
      end
      collection do
        get 'query'
      end
    end
  end

  # Static information pages
  match 'info' => 'info#index', :via => :get
  match 'info/faq' => 'info#faq', :via => :get
  match 'info/privacy' => 'info#privacy', :via => :get

  # unAPI service
  match 'unapi' => 'unapi#index', :via => :get

  # Start off on the search page (it's the part you can
  # do without being logged in)
  root :to => 'search#index'
end
