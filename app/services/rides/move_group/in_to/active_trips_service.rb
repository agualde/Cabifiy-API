# frozen_string_literal: true

module Rides
  module MoveGroup
    module InTo
      class ActiveTripsService < BaseService
        attr_accessor :hash, :journey, :car

        def initialize(car, journey)
          @car = car
          @journey = journey
          initialize_trips
          @hash = {}
        end

        def call
          hash[journey['id'].to_s] = {
            'car' => car,
            'journey' => {
              'id' => journey['id'],
              'people' => journey['people']
            }
          }

          trips << hash
          Cache::UpdateValueService.new('active_trips', trips).call
        end
      end
    end
  end
end
