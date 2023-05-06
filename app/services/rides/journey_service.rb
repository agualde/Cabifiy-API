module Rides
  class JourneyService
    attr_accessor :journey

    def initialize(journey)
      @journey = journey
    end

    def call
      FindCarForGroupService.new(hash).call
      PutGroupInActiveJourneysService.new(hash).call
    end

    def hash
      {
        id: journey["id"],
        people: journey["people"]
        }
    end
  end
end
