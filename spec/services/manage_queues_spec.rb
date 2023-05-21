# frozen_string_literal: true

require 'rails_helper'

describe Rides::Manage::Queues do
  include_context 'cache usage'
  subject { described_class.new(valid_car_info).call }

  let(:time) { Time.zone.now }
  let(:valid_car_id) { '1' }
  let(:valid_car_info) do
    {
      'id' => 1,
      'seats' => 4,
      'available_seats' => 4
    }
  end

  let(:journey) do
    {
      'id' => 1,
      'people' => 4
    }
  end

  let(:queue_1) do
    {
      'id' => 2,
      'people' => 2,
      'time' => time
    }
  end

  let(:queue_2) do
    {
      'id' => 3,
      'people' => 2,
      'time' => time + 3.seconds
    }
  end

  let(:queue_3) do
    {
      'id' => 4,
      'people' => 1,
      'time' => time + 5.minutes
    }
  end

  let(:queues) do
    [
      [],
      [queue_1, queue_2],
      [queue_3],
      [],
      [],
      []
    ]
  end

  let(:expected_available_cars) do
    [
      { '1' => {
        'id' => 1,
        'seats' => 3,
        'available_seats' => 0
      } },
      {},
      {},
      {},
      {},
      {},
      {}
    ]
  end

  let(:expected_journeys) do
    { queue_1['id'].to_s => queue_1.slice('id', 'people'), queue_2['id'].to_s => queue_2.slice('id', 'people') }
  end
  let(:expected_active_trips) do
    [{ queue_1['id'].to_s => { 'car' => valid_car_info, 'journey' => queue_1.slice('id', 'people') } },
     { queue_2['id'].to_s => { 'car' => valid_car_info, 'journey' => queue_2.slice('id', 'people') } }]
  end

  let(:expected_queues) do
    [
      [],
      [],
      [queue_3],
      [],
      [],
      []
    ]
  end

  before do
    insert_cart_into_active_cars(valid_car_id, valid_car_info, available_cars)

    redis.set('queues', queues)
  end

  describe 'when executing service' do
    context 'when a group that fits in the recently freed car'
    it 'updates queue in redis' do
      subject

      updated_redis_queues = redis.get('queues')
      expect(updated_redis_queues).to eq(expected_queues)
    end

    it 'sends them on a journey' do
      subject

      updated_redis_journeys = redis.get('journeys')
      expect(updated_redis_journeys).to eq(expected_journeys)
    end

    it 'sends them on an active trip' do
      subject

      updated_redis_trips = redis.get('active_trips')
      expect(updated_redis_trips).to eq(expected_active_trips)
    end
  end
end
