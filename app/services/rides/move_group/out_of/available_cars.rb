# frozen_string_literal: true

module Rides
  module MoveGroup
    module OutOf
      class AvailableCars < BaseService
        attr_accessor :car

        def initialize(car)
          initialize_cars
          @car = car
        end

        def call
          cars[available_seats].delete(id)
          Cache::UpdateValueService.new('available_cars', cars).call
        end

        private

        def available_seats
          car['available_seats']
        end

        def id
          car['id'].to_s
        end
      end
    end
  end
end
