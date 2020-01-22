Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  namespace :admin do
    resources :replies
    resources :districts
    resources :authorizations
    resources :notices do
      post :analyze
    end
    resources :bulk_uploads
    resources :users do
      post :login
    end

    root to: "users#index"
  end

  namespace :api do
    resources :notices
    resources :users
  end

  post "/analyze_direct_upload" => "direct_uploads#analyze", as: :direct_upload_analyze

  resources :bulk_uploads do
    member do
      patch :purge
    end

    collection do
      post :bulk
    end
  end

  resources :notices do
    member do
      get :inspect
      get :share
      get :prepare
      get :suggest
      get :pdf
      patch :duplicate
      patch :polish
      patch :mail
      patch :enable
      patch :disable
      patch :analyze
      patch :purge
      patch :upload
    end

    collection do
      get :stats
      get :map
      post :bulk
      post :import
    end
  end

  resource :user
  resources :users, only: [:edit, :update, :destroy] do
    patch :confirmation_mail, on: :member
  end

  resources :districts

  resource :sitemap, only: :show

  scope '/p' do
    get  '/charge/:token', to: 'public#charge',  as: :public_charge
    get '/profile/:token', to: 'public#profile', as: :public_profile
  end

  scope '/auth' do
    get  '/offline_login/:nickname', to: 'sessions#offline_login' unless Rails.env.production?
    get  '/:provider/callback', to: 'sessions#create', as: :provider_callback
    get  '/failure', to: 'sessions#failure'
    get  '/destroy_alias_session', to: 'sessions#destroy_alias', as: :logout_alias
    get  '/destroy_session', to: 'sessions#destroy', as: :logout
    get  '/validation/:token', to: 'sessions#validation', as: :validation
    get  '/signup', to: 'sessions#signup', as: :signup
    get  '/ticket', to: 'sessions#ticket', as: :ticket
    get  '/login', to: 'sessions#login', as: :login
    get  '/email', to: 'sessions#email', as: :email_login
    post '/complete', to: 'sessions#complete', as: :complete
  end

  scope '/sessions' do
    get '/email', to: 'sessions#email'
    post '/email_signup', to: 'sessions#email_signup'
  end

  root 'home#index'

  get '/home', to: 'home#index', as: :home
  get '/map', to: 'home#map', as: :map
  get '/stats', to: 'home#stats', as: :stats
  get '/faq', to: 'home#faq', as: :faq
  get '/privacy', to: 'home#privacy', as: :privacy
  get '/year2019', to: 'home#year2019', as: :year2019
  get '/year2020', to: 'home#year2020', as: :year2020

  # dev
  get '/styleguide', to: 'styleguide#index'

  get '/404', to: "errors#not_found"
  get '/422', to: "errors#unacceptable"
  get '/500', to: "errors#internal_error"

  get '/ping', to: -> (env) { [200, {'Content-Type' => 'text/html'}, ['pong']] }
end
