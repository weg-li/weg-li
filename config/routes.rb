Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Sidekiq::Web => "/sidekiq", :constraints => AdminConstraint.new

  resources :apidocs, only: [:index]

  namespace :admin do
    resources :system, only: [:index]
    resources :users do
      get :login
      patch :merge
    end
    resources :exports
    resources :data_sets
    resources :districts do
      collection do
        get :bulk
        post :bulk_update
      end
    end
    resources :notices do
      post :analyze
    end
    resources :bulk_uploads
    resources :replies
    resources :snippets
    resources :charges
    resources :charge_variants
    resources :authorizations
    resources :brands

    get :system, to: "system#index", as: :system_status
    root to: "users#index"
  end

  namespace :api, constraints: { format: :json } do
    resources :notices do
      member { patch :mail }
    end
    resources :uploads, only: [:create]
  end

  resources :replies
  resources :snippets
  resources :brands, only: [:index, :show]

  resources :bulk_uploads do
    member { patch :purge }

    collection do
      post :bulk
      post :import
    end
  end

  resources :notices do
    member do
      get :inspect
      get :colors
      get :share
      get :suggest
      get :pdf
      get :winowig
      get :retrieve
      patch :forward
      patch :status
      patch :duplicate
      patch :mail
      patch :enable
      patch :disable
      patch :analyze
      patch :purge
      patch :upload
    end

    collection do
      get :dump
      get :stats
      get :map
      post :geocode
      post :bulk
      post :import
    end
  end

  resource :user, except: %i[create new index] do
    member do
      get :studi
      post :generate_export
      patch :confirmation_mail
      patch :signature
      patch :destroy_signature
    end
  end
  # https://github.com/rails/rails/issues/1769#issuecomment-301643924
  resolve("User") { [:user] }

  resources :districts do
    member { get :wegeheld }
  end

  resources :charges, only: %i[index show] do
    collection { get :list }
  end
  resources :exports, only: :index
  resource :sitemap, only: :show

  scope "/p" do
    get "/charge/:token", to: "public#charge", as: :public_charge
    get "/profile/:token", to: "public#profile", as: :public_profile
    get "/winowig/:user_token/:notice_token",
        to: "public#winowig",
        as: :public_winowig,
        defaults: {
          format: :xml,
        }
  end

  scope "/auth" do
    unless Rails.env.production?
      get "/offline_login/:nickname", to: "sessions#offline_login"
    end
    post "/twitter_murks", to: "sessions#twitter_murks"
    get "/:provider/callback", to: "sessions#create", as: :provider_callback
    post "/:provider/callback", to: "sessions#create" # just for Apple
    delete "/:provider", to: "sessions#disconnect"
    get "/failure", to: "sessions#failure"
    get "/destroy_alias_session",
        to: "sessions#destroy_alias",
        as: :logout_alias
    get "/destroy_session", to: "sessions#destroy", as: :logout
    get "/validation/:token", to: "sessions#validation", as: :validation
    get "/signup", to: "sessions#signup", as: :signup
    get "/ticket", to: "sessions#ticket", as: :ticket
    get "/login", to: "sessions#login", as: :login
    get "/email", to: "sessions#email", as: :email_login
    post "/complete", to: "sessions#complete", as: :complete
  end

  scope "/sessions" do
    get "/email", to: "sessions#email"
    post "/email_signup", to: "sessions#email_signup", as: :email_signup
  end

  root "home#index"

  get "/home", to: "home#index", as: :home
  get "/wegeheld", to: "home#wegeheld", as: :wegeheld
  get "/generator", to: "home#generator", as: :generator
  get "/imprint", to: "home#imprint", as: :imprint
  get "/map", to: "home#map", as: :map
  get "/leaderboard", to: "home#leaderboard", as: :leaderboard
  get "/stats", to: "home#stats", as: :stats
  get "/features", to: "home#features", as: :features
  get "/faq", to: "home#faq", as: :faq
  get "/api", to: "home#api", as: :api
  get "/violation", to: "home#violation", as: :violation
  get "/privacy", to: "home#privacy", as: :privacy
  get "/donate", to: "home#donate", as: :donate
  get "/year", to: "home#year", as: :year
  get "/year2022" => redirect("/year?year=2022")
  get "/year2021" => redirect("/year?year=2021")
  get "/year2020" => redirect("/year?year=2020")
  get "/year2019" => redirect("/year?year=2019")

  if Rails.env.development?
    get "/cdn-cgi/image/width=:width,height=:height,fit=:fit,quality=:quality/storage/:key.:extension",
        to: "styleguide#photo"
  end

  get "/styleguide", to: "styleguide#index"

  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"

  get "/ping",
      to: ->(env) { [200, { "Content-Type" => "text/html" }, ["pong"]] }
end
