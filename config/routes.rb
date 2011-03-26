Evotext::Application.routes.draw do
  # See how all your routes lay out with "rake routes"
  root :to => "documents#index"
  resources :documents do
    member do
      get 'terms'
      get 'text'
      get 'concordance'
    end
    collection do
      get 'search'
    end
  end
end
