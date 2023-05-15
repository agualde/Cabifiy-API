# frozen_string_literal: true

module Rides
  class IfGroupWaitingFindThemACar < BaseService
    attr_accessor :running, :queue_state, :wait_list, :longest_waiting_group_that_fits_in_car, :found_car

    def initialize(found_car)
      initialize_common_values
      @running = true
      @queue_state = false
      @wait_list = []
      @found_car = found_car
      @longest_waiting_group_that_fits_in_car = nil
    end

    def call
      if_group_waiting_find_them_car
      update_found_car
    end

    private

    def if_group_waiting_find_them_car
      return if queue_empty?

      wait_times = wait_list.collect { |x| x[:time] }
      longest_time = wait_times.min

      wait_list.each do |group|
        longest_waiting_group_that_fits_in_car = group.slice('id', 'people') if group[:time] == longest_time

        redis_queues.each do |queue|
          queue.shift if queue.first == longest_waiting_group_that_fits_in_car
        end

        FindCarForGroupService.new(longest_waiting_group_that_fits_in_car).call
      end
    end

    def update_found_car
      trips.each do |trip|
        next unless longest_waiting_group_that_fits_in_car

        if trip[longest_waiting_group_that_fits_in_car['id']]
          self.found_car = trip[longest_waiting_group_that_fits_in_car['id']]['car']
        end
      end
    end

    def queue_empty?
      fill_queue
      return true if wait_list.empty?

      false
    end

    def fill_queue
      redis_queues.each do |queue|
        next unless queue.first && queue.first['people'] <= found_car['available_seats']

        wait_list << queue.first
      end
    end
  end
end
