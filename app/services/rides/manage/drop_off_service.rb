# frozen_string_literal: true

module Rides
  module Manage
    class DropOffService
      attr_accessor :group

      def initialize(group)
        @group = group.to_s
      end

      def call
        generate_drop_off_service = GenerateDropOffService.new(group)
        return false unless generate_drop_off_service.call

        found_car = generate_drop_off_service.found_car
        some_service = IfGroupWaitingFindThemACar.new(found_car)
        some_service.call
        true
      end
    end
  end
end
