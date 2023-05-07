module Rides
  class PutGroupInActiveTripsService
    attr_accessor :hash, :trips, :journey, :car, :trips
    include Cache::Access

    def initialize(car, journey)
      @hash = {}
      @car = car
      @journey = journey
      @trips = active_trips
    end

    def call
      hash[journey[:id]] = {
        car: car, 
        journey: {
          id:journey[:id], 
          people: journey[:people]
        }
      }

      trips << hash
      redis.set("active_trips", trips)
    end
  end
end
