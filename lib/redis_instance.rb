module RedisInstance
  class << self
    def connect
      @redis_instance ||= Redis.new(
        url:       ENV['REDIS_URL'],
        namespace: ENV['REDIS_NAMESPACE']
      )
    end
  end
end
