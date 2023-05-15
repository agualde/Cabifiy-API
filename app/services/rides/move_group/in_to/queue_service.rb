# frozen_string_literal: true

module Rides
  module MoveGroup
    module InTo
      class QueueService
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
          (1..6).each do |i|
            next unless journey[:people] == i

            redis_queues[i - 1] << {
              id: journey[:id],
              people: journey[:people],
              time: Time.now
            }
          end

          redis.set('queues', redis_queues)
        end
      end
    end
  end
end
