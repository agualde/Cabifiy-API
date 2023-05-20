# frozen_string_literal: true

module Fleet
  module Create
    class CarsService < BaseService
      attr_accessor :incoming_cars, :invalid_car, :redis_store

      def initialize(incoming_cars)
        @incoming_cars = incoming_cars
        @invalid_car = false
        initialize_cars
      end

      def call
        incoming_cars.each do |car|
          @invalid_car = true unless car_is_valid(car)

          put_car_in_available_cars(car)
        end

        Cache::UpdateValueService.new('available_cars', cars).call
      end

      def failed?
        invalid_car
      end

      private

      def car_is_valid(car)
        return false unless car['id'].is_a?(Integer) && car['seats'].is_a?(Integer)

        true
      end

      def put_car_in_available_cars(car)
        (1..6).each do |i|
          next unless car['seats'] == i

          cars[i][car['id'].to_i] = {
            id: car['id'].to_i,
            seats: car['seats'].to_i,
            available_seats: car['seats'].to_i
          }
        end
      end
    end
  end
end
