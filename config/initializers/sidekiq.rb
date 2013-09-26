Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://106.186.24.130:6379', :namespace => 'mynamespace' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://106.186.24.130:6379', :namespace => 'mynamespace' }
end