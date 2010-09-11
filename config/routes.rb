Rbtorrent::Application.routes.draw do
  devise_for :users

  resources :torrents do
    resources :files, :controller => "torrent_file"

    member do
      post :start
      post :stop
      post :erase

    end

    collection do
      get :check
    end
  end

  root :to => "torrents#index"
end
