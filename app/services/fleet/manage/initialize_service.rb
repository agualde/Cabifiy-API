# frozen_string_literal: true

module Fleet
  module Manage
    class InitializeService
      attr_accessor :cars

      def initialize(cars)
        @cars = cars
      end

      def call
        Cache::ResetStructuresService.new.call

        pre_processor = PreProcessor::Cars.new(cars)
        return false unless pre_processor.valid?

        Fleet::Create::CarsService.new(cars).call
        true
      end
    end
  end
end
