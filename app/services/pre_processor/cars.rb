# frozen_string_literal: true

module PreProcessor
  class Cars
    attr_accessor :cars

    def initialize(cars)
      @cars = cars
    end

    def call
      cars.all? do |car|
        car_is_valid(car)
      end
    end

    private

    def car_is_valid(car)
      return false unless car['id'].is_a?(Integer) && car['seats'].is_a?(Integer) && car['seats'].between?(1, 6)

      true
    end

    alias valid? call
  end
end
