class NewsRepo
  class << self
    def load_news
      redis = RedisInstance.connect
      redis.lrem('news', 0, '') # delete blank
      
      news = redis.lrange('news', 0, -1) || []
      results = []
      
      news.each_with_index do |attrs, id|
        next if attrs.blank?
        obj = get_news_instance(attrs, id: id)
        results << obj if obj
      end
      
      results
    end

    def load_a_news(id)
      redis = RedisInstance.connect
      attrs = redis.lindex('news', id)
      get_news_instance(attrs, id: id) || {}
    end
    
    protected
    
    def get_news_instance(json_attrs, **more_attrs)
      News.new(JSON.parse(json_attrs).merge(more_attrs))
    rescue JSON::ParserError
      nil
    end
  end
end
