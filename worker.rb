# worker.rb
require "sidekiq"

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
  # config.redis = ConnectionPool.new(size: 5, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
  # config.redis = ConnectionPool.new(size: 25, &redis_conn)
end

class Worker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  # The current retry count is yielded. The return value of the block must be 
  # an integer. It is used as the delay, in seconds. 
  sidekiq_retry_in do |count|
    2 * (count + 1) # (i.e. 10, 20, 30, 40, 50)
  end

  # After retrying so many times, Sidekiq will call the sidekiq_retries_exhausted 
  # hook on your Worker if you've defined it. The hook receives the queued message 
  # as an argument. This hook is called right before Sidekiq moves the job to the DJQ.
  sidekiq_retries_exhausted do |msg, e|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(complexity)
    case complexity
      when "long"
        sleep 20
        puts "Long task complete"
      when "medium"
        sleep 10
        puts "Medium task complete"
      when "short"
        sleep 1
        # raise "It's broken"
        puts "Short task complete"
    end
  end
end

# Need to run redis locally

# need to start termal to watch what's happening, require worker.rb with -r
# bundle exec sidekiq -r ./worker.rb
# 

# other terminal: bundle exec irb -r ./worker.rb
# Worker.perform_async("short")


# clone project
# gem install redis
# bundle exec sidekiq -r ./worker.rb
# other terminal: bundle exec irb -r ./worker.rb

