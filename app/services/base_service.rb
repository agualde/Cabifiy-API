# frozen_string_literal: true

class BaseService
  include Cache::Values::All
  attr_accessor :trips, :cars, :redis_journeys, :redis_queues

  def initialize_common_values
    @trips = active_trips
    @cars = available_cars
    @redis_journeys = journeys
    @redis_queues = queues
  end

  def initialize_trips
    @trips = active_trips
  end

  def initialize_cars
    @cars = available_cars
  end

  def initialize_redis_journeys
    @redis_journeys = journeys
  end

  def initialize_redis_queues
    @redis_queues = queues
  end
end
