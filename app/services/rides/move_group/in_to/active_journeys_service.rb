# frozen_string_literal: true

module Rides
  module MoveGroup
    module InTo
      class ActiveJourneysService < BaseService
        attr_accessor :journey

        def initialize(journey)
          initialize_redis_journeys
          @journey = journey
        end

        def call
          redis_journeys[journey['id'].to_s] = {
            'id' => journey['id'],
            'people' => journey['people']
          }

          redis.set('journeys', redis_journeys)
        end
      end
    end
  end
end
