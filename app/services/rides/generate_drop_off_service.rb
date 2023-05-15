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
      find_journey_and_car

      if found_car.nil? | journey.nil?
        false
      else
        trigger_services
        update_seats
        true
      end
    end

    def update_seats
      new_available_seats = found_car['available_seats'] + journey['people']
      found_car['available_seats'] = new_available_seats
      Fleet::Update::Seats::LaunchService.new(found_car, new_available_seats, journey).call
    end

    def trigger_services
      MoveGroup::OutOf::Journeys.new(group).call
      MoveGroup::OutOf::AvailableCars.new(found_car).call
      MoveGroup::OutOf::ActiveTrips.new(group).call
    end

    def find_journey_and_car
      trips.each do |trip|
        next unless trip.keys == [group]

        self.found_car = trip[group]['car']
        self.journey = trip[group]['journey']
      end
    end
  end
end
