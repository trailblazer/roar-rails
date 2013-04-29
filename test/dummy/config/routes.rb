Dummy::Application.routes.draw do
  get ':controller(/:action(/:id(.:format)))'
  post ':controller(/:action(/:id(.:format)))'
  put ':controller(/:action(/:id(.:format)))'
  delete ':controller(/:action(/:id(.:format)))'
  resources :singers
end
