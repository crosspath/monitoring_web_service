require_relative 'config_store'

module RedisFacade
  class << self
    def connect
      @redis_instance ||= begin
        params = Rails.configuration.redis[:sidekiq]
        Redis.new(url: params[:url], namespace: params[:namespace])
      end
    end
  end
end
