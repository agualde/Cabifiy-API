module Rides
  class PutGroupInActiveJourneysService
    include Cache::Access

    attr_accessor :journey, :redis_journeys

    def initialize(journey)
      @journey = journey
      @redis_journeys = journeys
    end

    def call
      redis_journeys[journey[:id]] = {
        id: journey[:id],
        people: journey[:people]
      }

      redis.set('journeys', redis_journeys)
    end
  end
end