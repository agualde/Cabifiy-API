# frozen_string_literal: true

module Rides
  module MoveGroup
    module OutOf
      class Queues < BaseService
        attr_accessor :collect_groups, :longest_waiting_group_that_fits_in_car, :found_car

        def initialize(found_car, collect_groups)
          @found_car = found_car
          @collect_groups = collect_groups
          @longest_waiting_group_that_fits_in_car = nil
          initialize_common_values
        end

        def call
          shift_and_send_queue_group
          return unless longest_waiting_group_that_fits_in_car.present?

          FindCarForGroupService.new(longest_waiting_group_that_fits_in_car.slice('id',
                                                                                  'people')).call
        end

        def shift_and_send_queue_group
          longest_time = fetch_longest_waiting_group

          collect_groups.each do |group|
            self.longest_waiting_group_that_fits_in_car = group if group['time'] == longest_time
            redis_queues.each do |queue|
              next unless queue.first == longest_waiting_group_that_fits_in_car

              queue.shift
              redis.set('queues', redis_queues)
            end
          end
        end

        def fetch_longest_waiting_group
          wait_times = collect_groups.collect { |x| x['time'] }
          wait_times.min
        end
      end
    end
  end
end
