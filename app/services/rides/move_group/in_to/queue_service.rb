# frozen_string_literal: true

module Rides
  module MoveGroup
    module InTo
      class QueueService < BaseService
        attr_accessor :journey

        def initialize(journey)
          @journey = journey
          initialize_redis_queues
        end

        def call
          put_group_in_correct_queue
          Cache::UpdateValueService.new('queues', redis_queues).call
        end

        def put_group_in_correct_queue
          (1..6).each do |i|
            next unless journey['people'] == i

            redis_queues[i - 1] << {
              id: journey['id'],
              people: journey['people'],
              time: Time.now
            }
          end
        end
      end
    end
  end
end
