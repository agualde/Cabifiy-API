# frozen_string_literal: true

module Rides
  module Manage
    module Execution
      class DropOffService
        attr_accessor :found_car, :group

        def initialize(found_car, group)
          @found_car = found_car
          @group = group
        end

        def call
          MoveGroup::OutOf::Journeys.new(group).call
          MoveGroup::OutOf::AvailableCars.new(found_car).call
          MoveGroup::OutOf::ActiveTrips.new(group).call
        end
      end
    end
  end
end
