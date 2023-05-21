# frozen_string_literal: true

module Rides
  module Manage
    class JourneyService
      attr_accessor :journey

      def initialize(journey)
        @journey = journey
      end

      def call
        pre_processor = PreProcessor::Journey.new(group)
        return false unless pre_processor.valid?

        Execute::FindCarService.new(group).call
        true
      end

      private

      def group
        journey.slice('id', 'people')
      end
    end
  end
end
