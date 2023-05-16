# frozen_string_literal: true

module OnBoardMethodsHelper
  include Cache::Access

  def insert_cart_into_active_cars(car_id, car_info, available_cars)
    available_cars[car_info['available_seats']][car_id] = car_info
    redis.set('available_cars', available_cars)
  end

  def insert_journey_into_journeys(journey, journeys)
    journeys[journey['id'].to_s] = journey
    redis.set('journeys', journeys)
  end

  def insert_trips_into_active_trips(car_id, car_info, journey, active_trips)
    active_trip_hash = {}
    active_trip_hash[car_id] = {
      'car' => car_info,
      'journey' => journey
    }
    active_trips << active_trip_hash
    redis.set('active_trips', active_trips)
  end
end
