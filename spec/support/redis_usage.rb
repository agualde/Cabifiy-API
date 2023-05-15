# frozen_string_literal: true

RSpec.shared_context 'redis usage' do
  include_context 'initialize common structures'

  include Cache::Instance

  let(:mock_redis) { instance_double(Redis) }

  before do
    redis.set('available_cars', available_cars)
    redis.set('journeys', journeys)
    redis.set('active_trips', active_trips)

    allow(Cache::RedisService).to receive(:instance).and_return(mock_redis)
    %w[available_cars active_trips journeys queues].each do |key|
      value = send(key)
      allow(mock_redis).to receive(:set).with(key, value)
      allow(mock_redis).to receive(:get).with(key).and_return(value)
    end
  end
end
