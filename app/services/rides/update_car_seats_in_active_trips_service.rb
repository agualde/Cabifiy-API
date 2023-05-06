module Rides
  class UpdateCarSeatsInActiveTripsService
    attr_accessor :car, :trips, :new_seat_count
    include Cache::Access

    def initialize(car, new_seat_count)
      @car = car
      @trips = active_trips
      @new_seat_count = new_seat_count
    end

    def call
      byebug
      trips.each do |active_trip_hash|
        byebug
        if active_trip_hash.values[0]["car"]["id"] == car[:id]
          active_trip_hash.values[0]["car"]["available_seats"] = new_seat_count
        end
      end

      redis.set("active_trips", trips)
    end
  end
end
