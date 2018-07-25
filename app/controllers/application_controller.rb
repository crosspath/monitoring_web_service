class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  include ApplicationHelper
  include RedisNews
  
  protected
  
  def connect_redis
    @redis = RedisFacade.connect
  end
end
