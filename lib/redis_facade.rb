module RedisFacade
  module_function
  
  def connect
    Redis.new(url: REDIS[:url], namespace: REDIS[:namespace])
  end
end
