# frozen_string_literal: true

module Rides
  class BaseService
    include Cache::Values::All
    attr_accessor :trips, :cars, :redis_journeys, :redis_queues

    def initialize_common_values
      @trips = active_trips
      @cars = available_cars
      @redis_journeys = journeys
      @redis_queues = queues
    end
  end
end
