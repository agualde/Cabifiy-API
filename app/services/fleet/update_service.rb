# frozen_string_literal: true

module Fleet
  class UpdateService
    attr_accessor :cars

    def initialize(cars)
      @cars = cars
    end

    def call
      Cache::ResetStructuresService.new.call
      Fleet::Initialize::CarsService.new(cars).call
    end
  end
end
