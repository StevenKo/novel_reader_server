require 'sidekiq/web'
NovelServer::Application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  namespace :api do
    namespace :v1 do
      
      resources :categories      
      resources :novels
      resources :articles
    end
  end
end
