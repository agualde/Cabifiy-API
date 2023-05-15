# frozen_string_literal: true

module Fleet
  module Initialize
    class CarsService
      attr_accessor :cars, :invalid_car, :redis_store

      include Cache::Access

      def initialize(cars)
        @cars = cars
        @invalid_car = false
        @redis_store = available_cars
      end

      def call
        cars.each do |car|
          @invalid_car = true unless car_is_valid(car)

          put_car_in_available_cars(car)
        end
        redis.set('available_cars', redis_store)
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

          redis_store[i][car['id'].to_i] = {
            id: car['id'].to_i,
            seats: car['seats'].to_i,
            available_seats: car['seats'].to_i
          }
        end
      end
    end
  end
end
