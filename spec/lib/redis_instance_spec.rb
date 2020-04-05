require 'redis'
require_relative '../../lib/redis_instance'

RSpec.describe RedisInstance do
  it 'returns Redis instance on connect' do
    redis = RedisInstance.connect
    expect(redis).to be_instance_of(Redis)
  end
end
