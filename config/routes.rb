Evotext::Application.routes.draw do
  # See how all your routes lay out with "rake routes"
  root :to => "search#query"

  match 'doc/:id' => 'doc#show'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
