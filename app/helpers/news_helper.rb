module NewsHelper
  def create_news(news)
    @redis.lpush('news', news.to_json)
  end

  def update_news(news, id)
    @redis.lset('news', id, news.to_json)
  end

  def delete_news(id)
    @redis.lset('news', id, nil)
  end

  def delete_blank
    @redis.lrem('news', 0, '')
  end

  def load_news(first = 0, last = -1)
    delete_blank
    news = @redis.lrange('news', first, last) || []
    news.reject(&:blank?).map.with_index do |x, k|
      begin
        j = JSON.parse(x)
        j.merge('index' => k)
      rescue
        nil
      end
    end.compact
  end

  def load_a_news(id)
    j = @redis.lindex('news', id)
    JSON.parse(j) rescue {}
  end
end
