# frozen_string_literal: true

module Rides
  module Execute
    class FindCarService < BaseService
      attr_accessor :journey, :riding

      def initialize(journey)
        @journey = journey
        @riding = false
        initialize_cars
      end

      def call
        find_car_for_group

        MoveGroup::InTo::QueueService.new(journey).call unless riding
      end

      private

      def find_car_for_group
        (journey['people']..6).each do |i|
          cars_that_fit_group = check_cars_index(i)
          next unless cars_that_fit_group.present?

          found_car = cars_that_fit_group.first[1]
          Execute::Secuence::JourneyService.new(found_car, journey).call
          @riding = true
          break
        end
      end

      def check_cars_index(index)
        cars[index]
      end
    end
  end
end
