# coding: UTF-8

Evotext::Application.routes.draw do
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
  
  resource :about, :only => [:index]  
  match "unapi(/:id)" => 'unapi#index', :as => 'unapi'
  
  root :to => "documents#index"
end

ActionDispatch::Routing::Translator.translate_from_file('config', 'routes-i18n.yml')

