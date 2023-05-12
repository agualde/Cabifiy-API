# frozen_string_literal: true

module Rides
  class SeatsUpdateService
    attr_accessor :car, :new_available_seats, :journey

    def initialize(car, new_available_seats, journey)
      @car = car
      @new_available_seats = new_available_seats
      @journey = journey
    end

    def call
      UpdateCarSeatsInActiveCarsService.new(car, new_available_seats).call
      UpdateCarSeatsInActiveTripsService.new(car, new_available_seats, journey).call
    end
  end
end
