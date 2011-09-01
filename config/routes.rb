# coding: UTF-8

RLetters::Application.routes.draw do
  # See how all your routes lay out with "rake routes"
  resources :documents, :only => [:index, :show] do
    member do
      get 'terms'
      get 'text'
      get 'concordance'
    end
    collection do
      get 'search'
    end
    
    resource :link, :only => [:none] do
      member do
        get 'targets'
        get 'mendeley'
        get 'citeulike'
      end
    end
    
    resource :export, :only => [:none] do
      member do
        get 'formats'
        get 'ris'
        get 'bibtex'
        get 'endnote'
        get 'rdf'
        get 'turtle'
        get 'marc'
        get 'marcxml'
        get 'mods'
      end
    end
  end
  
  match "about(/:action)", :controller => 'about', :as => 'about'
  match "help(/:id)", :controller => 'help', :action => 'message', :constraints => { :id => /[^\/]+/ }, :as => 'help'
  match "unapi(/:id)" => 'unapi#index', :as => 'unapi'
  match "options(/:action)", :controller => 'options', :as => 'options'
  
  root :to => "documents#index"
end

