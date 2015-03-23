Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root 'pages#show', page: 'home'

  # User
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  get '/user', to: 'users#show', as: 'profile'
  # get '/user/terminate', to: 'users#terminate', as: 'terminate_user'

  # delete '/provider/:id', to: 'identities#destroy', as: 'destroy_provider'
  # delete '/user', to: 'users#destroy', as: 'destroy_user'

  # logout
  # match '/signout', via: [:get, :post], to: 'sessions#destroy'

  # files
  scope '/service/:identity_id' do
    resources :files, only: [:create, :new, :destroy], path_names: {new: 'add'}
    get '/files/browse', to: 'files#browse'
    get '/files/download/:id', to: 'files#download_url'
  end
  get '/get/:download_hash/:name', to: 'files#download', :via => :all

  # search
  get '/search/:query', to: 'search#find', :defaults => { :format => 'json' }
  get '/search', to: 'search#home', as: 'search'
end
