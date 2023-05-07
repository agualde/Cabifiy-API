module Rides
  class JourneyQueueService
    attr_accessor :journey, :redis_queues
    include Cache::Access

    def initialize(journey)
      @journey = journey
      @redis_queues = queues
    end

    def call
      journey_queue
    end

    def journey_queue
      for i in 1..6
        if journey[:people] == i
          redis_queues[i -1] << {
              id: journey[:id],
              people: journey[:people],
              time: Time.now
            }
        end
      end

      redis.set("queues", redis_queues)
    end
  end
end
