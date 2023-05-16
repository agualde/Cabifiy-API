# frozen_string_literal: true

require 'rails_helper'

describe Rides::IfGroupWaitingFindThemACar do
  include_context 'cache usage'
  subject { described_class.new(valid_car_info).call }

  let(:time) { Time.zone.now }
  # let(:group) { 1 }
  let(:valid_car_id) { '1' }
  let(:valid_car_info) do
    {
      'id' => 1,
      'seats' => 3,
      'available_seats' => 3
    }
  end

  let(:journey) do
    {
      'id' => 1,
      'people' => 2
    }
  end

  let(:queues) do
    [
      [],
      [],
      [],
      [{
        'id' => 1,
        'people' => 2,
        'time' => time
      }],
      [],
      []
    ]
  end

  let(:expected_available_cars) do
    [
      {},
      {
        '1' => {
          'id' => 1,
          'seats' => 3,
          'available_seats' => 1
        }
      },
      {},
      {},
      {},
      {},
      {}
    ]
  end

  let(:expected_journeys) { { journey['id'].to_s => journey } }
  let(:expected_active_trips) do
    [{ valid_car_id.to_s => { 'car' => valid_car_info, 'journey' => journey } }]
  end

  let(:expected_queues) do
    [
      [],
      [],
      [],
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
