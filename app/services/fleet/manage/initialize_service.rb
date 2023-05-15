# frozen_string_literal: true

module Fleet
  module Manage
    class InitializeService
      attr_accessor :cars

      def initialize(cars)
        @cars = cars
      end

      def call
        byebug
        Cache::ResetStructuresService.new.call
        Fleet::Create::CarsService.new(cars).call
      end
    end
  end
end
