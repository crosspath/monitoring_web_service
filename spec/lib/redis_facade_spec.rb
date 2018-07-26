require_relative '../../lib/redis_facade'

RSpec.describe RedisFacade do
  it 'returns Redis instance on connect' do
    redis = RedisFacade.connect
    expect(redis).to be_instance_of(Redis)
  end
end
