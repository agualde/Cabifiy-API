# frozen_string_literal: true

module Rides
  class DropOffService < BaseService
    attr_accessor :group, :group_not_found, :found_car

    include Cache::Access

    def initialize(group)
      initialize_common_values
      @group = group.to_s
    end

    def call
      generate_drop_off_service = GenerateDropOffService.new(group)
      # return false unless
      generate_drop_off_service.call
      return true
      found_car = generate_drop_off_service.found_car
      some_service = SomeService.new(found_car)
      some_service.call while some_service.running
    end
  end
end
