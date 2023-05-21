# frozen_string_literal: true

module Rides
  module Helpers
    module Queues
      class FindLongestWaitingGroup
        attr_accessor :collect_groups

        def initialize(collect_groups)
          @collect_groups = collect_groups
        end

        def call
          find_longest_waiting_group
        end

        private

        def find_longest_waiting_group
          longest_time = fetch_longest_wait_time

          collect_groups.select do |group|
            group['time'] == longest_time
          end.first
        end

        def fetch_longest_wait_time
          wait_times = collect_groups.collect { |x| x['time'] }
          wait_times.min
        end
      end
    end
  end
end
