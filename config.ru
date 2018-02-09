# config.ru
require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end
# What should I use for the url/db?


require "sidekiq/web"
run Sidekiq::Web

# From terminal, rackup and then check port