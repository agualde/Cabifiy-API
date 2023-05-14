# frozen_string_literal: true

module Rides
  class UpdateCarSeatsInActiveCarsService
    attr_accessor :car, :new_seat_count, :cars

    include Cache::Access

    def initialize(car, new_seat_count)
      @car = car
      @cars = available_cars
      @new_seat_count = new_seat_count
    end

    def call
      move_car_in_hash_and_update_seats
    end

    def move_car_in_hash_and_update_seats
      cars[available_seats].delete(id.to_s)

      cars[new_seat_count][id] = {
        id: id,
        seats: seats,
        available_seats: new_seat_count
      }

      redis.set('available_cars', cars)
    end

    def available_seats
      car['available_seats']
    end

    def id
      car['id']
    end

    def seats
      car['seats']
    end
  end
end
