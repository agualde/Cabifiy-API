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
          delete_group_from_journeys
          redis.set('journeys', redis_journeys)
        end

        def delete_group_from_journeys
          redis_journeys.delete(group)
        end
      end
    end
  end
end
