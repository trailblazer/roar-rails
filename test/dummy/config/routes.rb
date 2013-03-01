Dummy::Application.routes.draw do
  get ':controller(/:action(/:id(.:format)))'
  root :to => 'musician#index'
  resources :singers
end
