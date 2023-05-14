# frozen_string_literal: true

module Rides
  class FindCarForGroupService
    attr_accessor :journey, :cars, :riding

    include Cache::Values::AvailableCars

    def initialize(journey)
      @journey = journey
      @cars = available_cars
      @riding = false
    end

    def call
      find_car_for_group

      JourneyQueueService.new(@journey).call unless @riding
    end

    def find_car_for_group
      (journey[:people]..6).each do |i|
        next unless cars[i].present?

        car = cars[i].first[1]

        new_available_seats = car['available_seats'] - journey[:people]

        MoveGroup::InTo::ActiveTripsService.new(car, journey).call
        MoveGroup::InTo::ActiveJourneysService.new(journey).call
        SeatsUpdateService.new(car, new_available_seats, journey).call

        @riding = true
        break
      end
    end
  end
end
