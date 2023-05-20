# frozen_string_literal: true

module Rides
  module Manage
    class Queues < BaseService
      attr_accessor :running, :queue_state, :collect_groups, :found_car

      def initialize(found_car)
        initialize_common_values
        @running = true
        @collect_groups = []
        @found_car = found_car
      end

      def call
        check_queues
      end

      private

      def check_queues
        return false if fetch_collect_groups

        MoveGroup::OutOf::Queues.new(found_car, collect_groups).call
        retrigger_queue
        true
      end

      def retrigger_queue
        self.collect_groups = []
        check_queues
      end

      def fetch_collect_groups
        redis_queues.each do |queue|
          next unless queue.first && queue.first['people'] <= found_car['available_seats']

          collect_groups << queue.shift
          Cache::UpdateValueService.new('queues', redis_queues).call
        end

        collect_groups.empty?
      end
    end
  end
end
