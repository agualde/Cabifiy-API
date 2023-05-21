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
        queue = fetch_valid_queue_candidates.compact
        return false unless queue.compact.any?

        group = Helpers::Queues::FindLongestWaitingGroup.new(queue).call
        MoveGroup::OutOf::Queues.new(found_car, group).call
        true
      end

      def fetch_valid_queue_candidates
        redis_queues.map do |queue|
          next unless queue.first && queue.first['people'] <= found_car['available_seats']

          queue.first
        end
      end
    end
  end
end
