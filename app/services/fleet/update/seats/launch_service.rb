# frozen_string_literal: true

module Fleet
  module Update
    module Seats
      class LaunchService
        attr_accessor :car, :new_available_seats, :journey

        def initialize(car, new_available_seats, journey)
          @car = car
          @new_available_seats = new_available_seats
          @journey = journey
        end

        def call
          Update::Seats::ActiveCarsService.new(car, new_available_seats).call
          Update::Seats::ActiveTripsService.new(car, new_available_seats, journey).call
        end
      end
    end
  end
end
