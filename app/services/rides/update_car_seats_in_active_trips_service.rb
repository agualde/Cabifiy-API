# frozen_string_literal: true

module Rides
  class UpdateCarSeatsInActiveTripsService
    attr_accessor :car, :trips, :new_seat_count, :journey

    include Cache::Access

    def initialize(car, new_seat_count, journey)
      @car = car
      @trips = active_trips
      @new_seat_count = new_seat_count
      @journey = journey
    end

    def call
      trips.each do |active_trip_hash|
        next unless active_trip_hash.values[0]['car']['id'] == car['id']

        active_trip_hash.values[0]['car']['available_seats'] = new_seat_count

        redis.set('active_trips', trips)
      end
    end
  end
end
