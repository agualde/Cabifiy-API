# frozen_string_literal: true

module Rides
  class SomeService < BaseService
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
      check_queue
      return unless queue_state

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
          found_car = trip[longest_waiting_group_that_fits_in_car['id']]['car']
        end
      end
    end

    def check_queue
      redis_queues.each do |queue|
        next if found_car.nil?
        next unless queue.first && queue.first['people'] <= found_car['available_seats']

        queue_state = true
        wait_list << queue.first
      end

      running = false if wait_list.empty?
    end
  end
end
