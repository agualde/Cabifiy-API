# frozen_string_literal: true

module Rides
  class GenerateDropOffService < BaseService
    attr_accessor :group, :found_car, :group_not_found, :journey, :new_available_seats

    def initialize(group)
      initialize_common_values
      @group = group.to_s
      @group_not_found = false
      @found_car = nil
      @journey = nil
      @new_available_seats = nil
    end

    def call
      generate_drop_off
    end

    def generate_drop_off
      trips.each do |trip|
        next unless trip.keys == [group]

        self.found_car = trip[group]['car']
        self.journey = trip[group]['journey']
      end

      if found_car.nil? | journey.nil?
        false
      else
        MoveGroup::OutOf::Journeys.new(group).call
        MoveGroup::OutOf::AvailableCars.new(@found_car).call
        MoveGroup::OutOf::ActiveTrips.new(group).call

        self.new_available_seats = found_car['available_seats'] + journey['people']
        SeatsUpdateService.new(found_car, new_available_seats, journey).call
        update_found_car
        true
      end
    end

    def update_found_car
      found_car['available_seats'] = new_available_seats
    end
  end
end
