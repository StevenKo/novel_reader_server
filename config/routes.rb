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
          get 'search'
        end
        member do 
          get 'detail_for_save'
        end
      end
      resources :articles,:only => [:index, :show]
    end
  end
end
