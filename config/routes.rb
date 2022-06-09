Rails.application.routes.draw do
  resources :journeys
  get '/status', to: 'pages#status'

  get '/all_cars', to: 'api#index_cars'

  put '/cars', to: 'api#update'

  get '/cars', to: 'api#error'
  post '/cars', to: 'api#error'
  patch '/cars', to: 'api#error'
  delete '/cars', to: 'api#error'

  get '/all_journeys', to: 'api#index_journeys'

  post '/journey', to: 'api#create'

  post '/dropoff', to: 'api#drop_off'

  post '/locate', to: 'api#locate'

  get '/journey', to: 'api#error'
  put '/journey', to: 'api#error'
  patch '/journey', to: 'api#error'
  delete '/journey', to: 'api#error'

end
