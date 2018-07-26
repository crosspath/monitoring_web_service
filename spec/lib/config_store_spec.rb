require_relative '../../lib/config_store'

RSpec.describe ConfigStore do
  it 'loads required files' do
    # ConfigStore.load(...) executed in config/application.rb
    expect(ConfigStore.config).to respond_to(:keys)
    expect(ConfigStore.config.keys).to include(:app, :admins, :redis)
  end
end
