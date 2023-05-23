# frozen_string_literal: true

module Rides
  module Manage
    class LocationService
      attr_accessor :group

      def initialize(group)
        @group = group.to_s
      end

      def call
        pre_processor = PreProcessor::GroupId.new(group)
        return false unless pre_processor.valid?

        Execute::LocationService.new(group).call
      end
    end
  end
end
