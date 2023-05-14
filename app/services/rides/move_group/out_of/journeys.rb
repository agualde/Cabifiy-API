# frozen_string_literal: true

module Rides
  module MoveGroup
    module OutOf
      class Journeys < BaseService
        attr_accessor :group

        def initialize(group)
          initialize_redis_journeys
          @group = group
        end

        def call
          redis_journeys.delete(group)
          redis.set('journeys', redis_journeys)
        end
      end
    end
  end
end
