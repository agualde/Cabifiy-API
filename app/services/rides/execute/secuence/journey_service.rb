# frozen_string_literal: true

module Rides
  module Execute
    module Secuence
      class JourneyService
        attr_accessor :car, :group

        def initialize(car, group)
          @car = car
          @group = group
        end

        def call
          MoveGroup::InTo::ActiveTripsService.new(car, group).call
          MoveGroup::InTo::JourneysService.new(group).call
          Fleet::Update::Seats::LaunchService.new(car, new_available_seats, group).call
        end

        private

        def new_available_seats
          car['available_seats'] - group['people']
        end
      end
    end
  end
end
