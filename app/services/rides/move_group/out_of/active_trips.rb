# frozen_string_literal: true

module Rides
  module MoveGroup
    module OutOf
      class ActiveTrips < BaseService
        attr_reader :group

        def initialize(group)
          initialize_trips
          @group = group
        end

        def call
          trips.delete_if { |h| h[group] }
          redis.set('active_trips', trips)
        end
      end
    end
  end
end
