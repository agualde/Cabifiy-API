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

      MoveGroup::InTo::QueueService.new(journey).call unless @riding
    end

    def find_car_for_group
      (journey[:people]..6).each do |i|
        cars_that_fit_group = check_cars_index(i)
        next unless cars_that_fit_group.present?

        car = cars_that_fit_group.first[1]
        new_available_seats = car['available_seats'] - journey[:people]

        Manage::Execution::JourneyService.new(car, new_available_seats, journey).call

        @riding = true
        break
      end
    end

    def check_cars_index(index)
      cars[index]
    end
  end
end
