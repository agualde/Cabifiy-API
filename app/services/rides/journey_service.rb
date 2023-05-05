module Rides
  class JourneyService
    include RedisInstance
    attr_accessor :journey, :redis_journeys

    def initialize(journey)
      @journey = journey
      @redis_journeys = journeys
    end

    def call
      hash = {
      id: journey["id"],
      people: journey["people"]
      }

      FindCarForGroupService.new(hash).call

      redis_journeys[hash[:id]] = {
        id: hash[:id],
        people: hash[:people]
      }

      redis.set('journeys', redis_journeys)
    end
  end
end
