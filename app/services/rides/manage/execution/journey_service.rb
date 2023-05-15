# frozen_string_literal: true

module Rides
  module Manage
    module Execution
      class JourneyService
        attr_accessor :car, :new_available_seats, :journey

        def initialize(car, new_available_seats, journey)
          @car = car
          @new_available_seats = new_available_seats
          @journey = journey
        end

        def call
          MoveGroup::InTo::ActiveTripsService.new(car, journey).call
          MoveGroup::InTo::ActiveJourneysService.new(journey).call
          Fleet::Update::Seats::LaunchService.new(car, new_available_seats, journey).call
        end
      end
    end
  end
end
