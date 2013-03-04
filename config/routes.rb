require 'sidekiq/web'
NovelServer::Application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  namespace :api do
    namespace :v1 do
      
      resources :categories, :only => [:index]
      resources :novels,:only => [:index, :show] do
        collection do
          get 'category_hot'
          get 'category_this_week_hot'
          get 'category_recommend'
          get 'hot'
          get 'this_week_hot'
          get 'this_month_hot' 
        end
      end
      resources :articles,:only => [:index]
    end
  end
end
