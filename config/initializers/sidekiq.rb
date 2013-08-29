Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://106.187.97.63:6379', :namespace => 'mynamespace' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://106.187.97.63:6379', :namespace => 'mynamespace' }
end