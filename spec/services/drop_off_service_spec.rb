# frozen_string_literal: true

require 'rails_helper'

describe Rides::GenerateDropOffService do
  include_context 'redis usage'

  subject { described_class.new(group).call }
  let(:group) { 1 }
  let(:valid_car_id) { '1' }
  let(:valid_car_info) do
    {
      'id' => 1,
      'seats' => 3,
      'available_seats' => 0
    }
  end

  let(:untouched_car_id) { '2' }
  let(:untouched_car_info) do
    {
      'id' => 2,
      'seats' => 4,
      'available_seats' => 2
    }
  end

  let(:journey) do
    {
      'id' => 1,
      'people' => 3
    }
  end

  let(:untouched_journey) do
    {
      'id' => 2,
      'people' => 2
    }
  end

  let(:expected_available_cars) do
    [
      {},
      {},
      { untouched_car_id => untouched_car_info },
      {
        '1' => {
          'id' => 1,
          'seats' => 3,
          'available_seats' => 3
        }
      },
      {},
      {},
      {}
    ]
  end

  let(:expected_journeys) { { untouched_journey['id'].to_s => untouched_journey } }
  let(:expected_active_trips) do
    [{ untouched_car_id => { 'car' => untouched_car_info, 'journey' => untouched_journey } }]
  end

  before do
    insert_cart_into_active_cars(valid_car_id, valid_car_info, available_cars)
    insert_cart_into_active_cars(untouched_car_id, untouched_car_info, available_cars)

    insert_journey_into_journeys(journey, journeys)
    insert_journey_into_journeys(untouched_journey, journeys)

    insert_trips_into_active_trips(valid_car_id, valid_car_info, journey, active_trips)
    insert_trips_into_active_trips(untouched_car_id, untouched_car_info, untouched_journey, active_trips)
  end

  describe 'when generating a drop off' do
    context 'when a group is in a journey'
    it 'updates available_cars in redis with the appropriate amount of seats' do
      subject

      updated_redis_cars = redis.get('available_cars')
      expect(updated_redis_cars).to eq(expected_available_cars)
    end

    it 'updates journeys in redis by deleting the correct journey' do
      subject

      updated_redis_journeys = redis.get('journeys')
      expect(updated_redis_journeys).to eq(expected_journeys)
    end

    it 'updates active_trips in redis by deleting the correct trips' do
      subject

      updated_active_trips = redis.get('active_trips')
      expect(updated_active_trips).to eq(expected_active_trips)
    end
  end
end
