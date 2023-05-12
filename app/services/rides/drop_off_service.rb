# frozen_string_literal: true

module Rides
  class DropOffService < BaseService
    attr_accessor :group, :group_not_found, :found_car

    include Cache::Access

    def initialize(group)
      initialize_common_values
      @group = group.to_s
      @group_not_found = false
      @found_car = nil
    end

    def call
      generate_drop_off
      some_service = SomeService.new(@found_car)

      some_service.call while some_service.running
    end

    private

    def generate_drop_off
      trips.each do |trip|
        next unless trip.keys == [group]

        @found_car = trip[group]['car']
        @journey = trip[group]['journey']
        trips.delete_if { |h| h[group] }

        redis_journeys.delete(group) if redis_journeys[group]
      end

      if @found_car.nil? || @journey.nil?
        @group_not_found = true
      else

        cars[@found_car['available_seats']].delete(@found_car['id'].to_s)

        new_available_seats = @found_car['available_seats'] + @journey['people']
        @found_car['available_seats'] = new_available_seats

        cars[@found_car['available_seats']][@found_car['id']] = {
          id: @found_car['id'],
          seats: @found_car['seats'],
          available_seats: @found_car['available_seats']
        }

        SeatsUpdateService.new(@found_car, new_available_seats, @journey).call

        redis.set('available_cars', cars)
        redis.set('journeys', redis_journeys)
        redis.set('active_trips', trips)
      end
    end
  end
end
