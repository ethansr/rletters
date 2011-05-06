# coding: UTF-8

Evotext::Application.routes.draw do
  # See how all your routes lay out with "rake routes"
  root :to => "documents#index"
  resources :documents do
    member do
      get 'terms'
      get 'text'
      get 'concordance'
      
      get 'mendeley'
      get 'citeulike'
    end
    collection do
      get 'search'
    end
  end
  match "export/:action", :controller => 'export', :via => :get
  match "unapi" => 'unapi#index', :via => :get
end
