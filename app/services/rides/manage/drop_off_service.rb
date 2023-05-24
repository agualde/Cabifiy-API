# frozen_string_literal: true

module Rides
  module Manage
    class DropOffService
      attr_accessor :group

      def initialize(group)
        @group = group
      end

      def call
        pre_processor = PreProcessor::GroupId.new(group)
        return false unless pre_processor.valid?

        execute_drop_off = Execute::DropOffService.new(group.to_s)
        return false unless execute_drop_off.call

        found_car = execute_drop_off.found_car
        manage_queues = Manage::Queues.new(found_car)
        manage_queues.call
        true
      end
    end
  end
end
