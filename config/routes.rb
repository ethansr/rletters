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
      
      get 'ris'
      get 'bib'
      get 'enw'
      get 'rdf'
      get 'ttl'
      get 'marc'
      get 'xml_marc'
      get 'xml_mods'
    end
    collection do
      get 'search'
    end
  end
  match "unapi" => 'unapi#index', :via => :get
end
