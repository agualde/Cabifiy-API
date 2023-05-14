# frozen_string_literal: true

module Rides
  class LocateGroupFromCarService < BaseService
    include Cache::Values::All
    attr_accessor :group, :group_waiting, :found_car

    def initialize(group)
      initialize_common_values
      @group = group.to_s
      @group_waiting = false
      @group_not_found = false
      @found_car = {}
    end

    def call
      find_car_from_group
 
      if found_car.present?
        { car: found_car, status: :ok }
      elsif group_waiting
        { car: nil, status: :no_content }
      else
        { car: nil, status: 404 }
      end
    end

    private

    def find_car_from_group
      trips.each do |trip|
        if trip[group].present?
          @found_car = trip[group]['car'].slice('id', 'seats')
        elsif trip[group].nil?
          group_waiting?
        else
          @group_not_found = true
        end
      end
    end

    def group_waiting?
      redis_queues.select do |queue|
        @group_waiting = queue.any? do |group|
          group['id'].to_s == @group
        end
      end
    end
  end
end
