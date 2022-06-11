Rails.application.routes.draw do
  resources :journeys
  get '/status', to: 'api#status'

  put '/cars', to: 'api#update'
  
  post '/journey', to: 'api#create'

  post '/dropoff', to: 'api#drop_off'

  post '/locate', to: 'api#locate'
  
  get '/cars', to: 'api#error'
  post '/cars', to: 'api#error'
  patch '/cars', to: 'api#error'
  delete '/cars', to: 'api#error'

  get '/journey', to: 'api#error'
  put '/journey', to: 'api#error'
  patch '/journey', to: 'api#error'
  delete '/journey', to: 'api#error'

end
