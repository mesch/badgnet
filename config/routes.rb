require 'subdomain'

Badgnet::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # API
  constraints(APISubdomain) do
    match '/' => "sites#home" # for now - will probably point to some help doc
    namespace :v1 do
      match '/' => "sites#home" # for now - will probably point to some help doc
      controller :clients do
        match '/clients/badges' => :badges, :via => :get
        match '/clients/feats' => :feats, :via => :get
      end
      controller :users do
        match '/users/badges' => :badges, :via => :get
        match '/users/feats' => :feats, :via => :get
      end
      controller :feats do
        match '/feats/log' => :log, :via => :post
      end
      controller :reports do
        match 'reports/client' => :client, :via => :get
        match 'reports/badges' => :badges, :via => :get
        match 'reports/feats' => :feats, :via => :get
      end
    end
  end
  
  # Client
  namespace :client do
    scope :via => :get do
      match '/' => :home
      match '/home' => :home
      match '/login' => :login
      match '/logout' => :logout
      match '/signup' => :signup
      match '/activate' => :activate
      match '/reactivate' => :reactivate
      match '/account'  => :account
      match '/change_email' => :change_email
      match '/change_password' => :change_password
      match '/forgot_password' => :forgot_password
      match '/badges' => :badges
      match '/badge' => :new_badge, :as => :new_badge
      match '/badge/:id' => :edit_badge, :as => :edit_badge
      match '/feat' => :new_feat, :as => :new_feat
      match '/feat/:id' => :edit_feat, :as => :edit_feat
      match '/images' => :images
    end
    scope :via => :post do
      match '/home' => :home
      match '/login' => :login
      match '/signup' => :signup
      match '/reactivate' => :reactivate
      match '/account' => :account
      match '/change_email' => :change_email
      match '/change_password' => :change_password
      match '/forgot_password' => :forgot_password
      match '/badge' => :create_badge, :as => :create_badge
      match '/badge/:id' => :update_badge, :as => :update_badge
      match '/feat' => :create_feat, :as => :create_feat
      match '/feat/:id' => :update_feat, :as => :update_feat
      match '/images' => :images_submit, :as => :images_submit
    end
  end
  
  # Admin
  namespace :admin do
    match '/', :to => "admin#index", :as => :home
    resources :clients do
      post 'multi_update', :on => :collection
      post 'generate_api_key', :on => :member
    end
  end

  # Public Site
  match '/privacy', :to => "application#privacy"
  match '/tos', :to => "application#tos"
  
  root :to => "sites#home"

end
