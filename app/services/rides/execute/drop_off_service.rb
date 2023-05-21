# frozen_string_literal: true

module Rides
  module Execute
    class DropOffService < BaseService
      attr_accessor :group, :found_car, :group_not_found, :journey, :new_available_seats, :car

      def initialize(group)
        initialize_common_values
        @group = group.to_s
        @group_not_found = false
        @found_car = nil
        @car = nil
        @journey = nil
        @new_available_seats = nil
      end

      def call
        generate_drop_off
        update_found_car
      end

      def generate_drop_off
        find_journey_and_car

        if car.nil? | journey.nil?
          false
        else
          Execute::Secuence::DropOffService.new(car, journey).call
          true
        end
      end

      def find_journey_and_car
        trips.each do |trip|
          next unless trip.keys == [group]

          self.journey = trip[group]['journey']
          self.car = trip[group]['car']
        end
      end

      def update_found_car
        car['available_seats'] = car['available_seats'] + journey['people']

        self.found_car = car
      end
    end
  end
end
