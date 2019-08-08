Rails.application.routes.draw do
  namespace :admin do
    resources :articles
    resources :authorizations
    resources :notices
    resources :users

    root to: "notices#index"
  end

  resources :notices do
    member do
      get :share
      patch :mail
      patch :enable
      patch :disable
      patch :analyse
      patch :purge
    end

    collection do
      get :map
      post :bulk
    end
  end

  resources :users do
    patch :confirmation_mail, on: :member
  end

  resources :articles

  resource :sitemap, only: :show

  scope '/p' do
    get  '/charge/:token', to: 'public#charge',  as: :public_charge
    get '/profile/:token', to: 'public#profile', as: :public_profile
  end

  scope '/auth' do
    get  '/offline_login/:nickname', to: 'sessions#offline_login' if Rails.env.development?
    get  '/:provider/callback',      to: 'sessions#create',     as: :provider_callback
    get  '/failure',                 to: 'sessions#failure'
    get  '/destroy_session',         to: 'sessions#destroy',    as: :logout
    get  '/validation/:token',       to: 'sessions#validation', as: :validation
    get  '/signup',                  to: 'sessions#signup',     as: :signup
    get  '/ticket',                  to: 'sessions#ticket',     as: :ticket
    get  '/login',                   to: 'sessions#login',      as: :login
    get  '/email',                   to: 'sessions#email',      as: :email_login
    post '/complete',                to: 'sessions#complete',   as: :complete
  end

  scope '/sessions' do
    get '/email', to: 'sessions#email'
    post '/email_signup', to: 'sessions#email_signup'
  end

  root 'notices#index', as: :authenticated_root, constraints: -> (request) { request.env["rack.session"].has_key?("user_id") }
  root 'home#index'

  get '/blog',     to: 'articles#index'
  get '/home',     to: 'home#index'
  get '/map',      to: 'home#map'
  get '/faq',      to: 'home#faq'
  get '/privacy',  to: 'home#privacy'

  # dev
  get '/styleguide', to: 'styleguide#index'

  get '/ping', to: -> (env) { [200, {'Content-Type' => 'text/html'}, ['pong']] }
end
