Rails.application.routes.draw do
  resources :journeys
  get '/status', to: 'pages#status', as: 'status'

  get '/all_cars', to: 'cars#index', as: 'all_cars'

  put '/cars', to: 'cars#update', as: 'cars'

  get '/cars', to: 'cars#error'
  post '/cars', to: 'cars#error'
  patch '/cars', to: 'cars#error'
  delete '/cars', to: 'cars#error'

  get '/all_journeys', to: 'journeys#index'
  post '/journey', to: 'journeys#create'

end
