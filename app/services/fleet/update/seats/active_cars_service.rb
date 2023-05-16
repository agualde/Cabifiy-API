# frozen_string_literal: true

module Fleet
  module Update
    module Seats
      class ActiveCarsService
        include Cache::Access
        attr_accessor :car, :new_seat_count, :cars

        def initialize(car, new_seat_count)
          @car = car
          @cars = available_cars
          @new_seat_count = new_seat_count
        end

        def call
          move_car_in_hash_and_update_seats
        end

        def move_car_in_hash_and_update_seats
          delete_car

          cars[new_seat_count][id] = {
            'id' => id_to_i,
            'seats' => seats,
            'available_seats' => new_seat_count
          }

          redis.set('available_cars', cars)
        end

        def delete_car
          cars[available_seats].delete(id)
        end

        def available_seats
          car['available_seats']
        end

        def id
          car['id'].to_s
        end

        def id_to_i
          id.to_i
        end

        def seats
          car['seats']
        end
      end
    end
  end
end
