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
          delete_active_trip
          Cache::UpdateValueService.new('active_trips', trips).call
        end

        private

        def delete_active_trip
          trips.delete_if { |h| h[group] }
        end
      end
    end
  end
end
