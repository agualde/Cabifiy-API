# frozen_string_literal: true

module Rides
  module Manage
    class JourneyService
      attr_accessor :journey

      def initialize(journey)
        @journey = journey
      end

      def call
        pre_processor = PreProcessor::Journey.new(hash)
        return false unless pre_processor.valid?

        Execute::FindCarService.new(hash).call
        true
      end

      def hash
        journey.slice('id', 'people')
      end
    end
  end
end
