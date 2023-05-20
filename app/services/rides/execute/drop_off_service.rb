# frozen_string_literal: true

module Rides
  module Execute
    class DropOffService < BaseService
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
          Execute::Secuence::DropOffService.new(found_car, journey).call
          true
        end
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
end
