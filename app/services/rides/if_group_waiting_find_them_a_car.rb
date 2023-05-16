# frozen_string_literal: true

module Rides
  class IfGroupWaitingFindThemACar < BaseService
    attr_accessor :running, :queue_state, :collect_groups, :found_car

    def initialize(found_car)
      initialize_common_values
      @running = true
      @collect_groups = []
      @found_car = found_car
    end

    def call
      if_group_waiting_find_them_car
    end

    private

    def if_group_waiting_find_them_car
      return if fetch_collect_groups

      MoveGroup::OutOf::Queues.new(found_car, collect_groups).call
      self.running = false
    end

    def fetch_collect_groups
      redis_queues.each do |queue|
        next unless queue.first && queue.first['people'] <= found_car['available_seats']

        collect_groups << queue.first
      end

      collect_groups.empty?
    end
  end
end
