class News
  include ActiveModel::Model
  
  attr_reader :id
  attr_accessor :title, :content, :date
  
  def initialize(attrs = {})
    attrs.symbolize_keys! if attrs.respond_to?(:symbolize_keys!)
    @id = attrs.delete(:id)
    super(attrs)
  end
  
  def save
    redis = RedisInstance.connect
    
    if @id
      # update
      redis.lset('news', @id, serialize)
    else
      # create
      redis.lpush('news', serialize)
    end
  end
  
  def destroy
    redis = RedisInstance.connect
    redis.lset('news', @id, nil)
  end
  
  protected
  
  def to_h
    [:id, :title, :content, :date].map do |attr|
      [attr, instance_variable_get("@#{attr}")]
    end.to_h
  end
  
  def serialize
    self.to_h.slice(:title, :content, :date).to_json
  end
end
