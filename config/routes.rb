Lagtv::Application.routes.draw do
  mount Forem::Engine, :at => "/forums"
  root :to => 'pages#home'  

  get 'login', to: 'sessions#new', as: 'login'
  get 'register', to: 'users#new', as: 'register'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  match "/my_profile" => "users#edit", :as => :my_profile
  match "/about" => "pages#about", :as => :about
  match "/latest_posts" => "pages#latest_posts", :as => :latest_posts
  match "/mark_all_as_viewed" => "users#mark_all_as_viewed", :as => :mark_all_as_viewed
  match "/streams" => "pages#streams", :as => :streams

  resources :sessions
  resources :password_reset
  resources :categories
  resources :users do
    resources :replays do
      collection do
        get 'page', :to => 'replays#user_page'
      end
    end
  end

  resources :replays do
    resources :comments

    collection do
      get 'download'
      get 'bulk_update'
    end
  end

  resources :announcements do
    member do
      get 'hide'
    end
  end

  resources :emails, :only => [:new, :create, :show, :index]
end
