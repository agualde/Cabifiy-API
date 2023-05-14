# frozen_string_literal: true

require 'rails_helper'

describe Rides::GenerateDropOffService do
  include Cache::Instance
  subject { described_class.new(group).call }
  let(:mock_redis) { instance_double(Redis) }
  let(:available_cars) do
      [
        { valid_car_id => valid_car_info },
        {},
        {},
        {},
        {},
        {},
        {}
      ]
  end

  let(:valid_car_id) { '1' }

  let(:valid_car_info) { 
    {
    'id'=>  1,
    'seats'=>  3,
    'available_seats'=>  0
    }
   }

  let(:journeys) do
    {
      '1'=> {
        'id'=>  1,
        'people'=>  3
      }
    }
  end

  let(:active_trips) do
    [
      {
        '1'=>  {
          'car'=>  {
            'id'=>  1,
            'seats'=>  3,
            'available_seats'=>  0
          },
          'journey'=>  {
            'id'=>  1,
            'people'=>  3
          }
        }
      }
    ]
  end

  let(:queues) do
    [
      [],
      [],
      [],
      [],
      [],
      []
    ]
  end

  let(:expected_available_cars) do
      [
        {},
        {},
        {},
        {
          1 => {
            :'id' => 1,
            :'seats' => 3,
            :'available_seats' => 3
          }
        },
        {},
        {},
        {}
      ]
  end

  let(:expected_journeys) { {} }
  let(:expected_active_trips) { [] }

  before do
    redis.set('available_cars', available_cars)
    allow(Cache::RedisService).to receive(:instance).and_return(mock_redis)
    %w[available_cars active_trips journeys queues].each do |key|
      value = send(key)
      allow(mock_redis).to receive(:set).with(key, value)
      allow(mock_redis).to receive(:get).with(key).and_return(value)
    end
  end

  describe 'when generating a drop off' do
    context 'when a group is in a journey'
    let(:group) { 1 }

    it 'updates available_cars in redis with the appropriate amount of seats' do
      initial_redis_cars =  redis.get('available_cars')
      subject
      
      updated_redis_cars = redis.get('available_cars')      
      expect(updated_redis_cars).to eq(expected_available_cars)
    end

    it 'updates journeys in redis by deleting the correct journey' do
      redis_journeys = redis.get('journeys')
      subject

      updated_redis_journeys = redis.get('journeys')  
      expect(updated_redis_journeys).to eq(expected_journeys)
    end

    it 'updates active_trips in redis by deleting the correct trips' do
      redis_active_trips = redis.get('active_trips')
      subject

      updated_active_trips = redis.get('active_trips')  
      expect(updated_active_trips).to eq(active_trips)
    end
  end
end
