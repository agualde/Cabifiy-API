# frozen_string_literal: true

module Rides
  module Execute
    module Secuence
      class DropOffService
        attr_accessor :car, :group

        def initialize(car, group)
          @car = car
          @group = group
        end

        def call
          MoveGroup::OutOf::Journeys.new(id).call
          MoveGroup::OutOf::AvailableCars.new(car).call
          MoveGroup::OutOf::ActiveTrips.new(id).call
          Fleet::Update::Seats::LaunchService.new(car, new_available_seats, group).call
        end

        private

        def new_available_seats
          car['available_seats'] + group['people']
        end

        def id
          group['id'].to_s
        end
      end
    end
  end
end
