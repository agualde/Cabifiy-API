# frozen_string_literal: true

module Rides
  class LocateGroupFromCarService < BaseService
    attr_accessor :group, :group_waiting, :car

    include Cache::Values::All

    def initialize(group)
      initialize_common_values
      @group = group.to_s
      @group_waiting = false
      @car = {}
    end

    def call
      find_car_from_group

      if @car.present?
        { car: @car, status: :ok }
      elsif group_waiting
        { car: nil, status: :no_content }
      else
        { car: nil, status: 404 }
      end
    end

    private

    def find_car_from_group
      trips.each do |trip|
        if trip[group]
          found_car = trip[group]['car']

          @car = {
            id: found_car['id'],
            seats: found_car['seats']
          }
        end

        if trip[group].nil?
          @group_waiting = true if redis_journeys[group]
          return nil
        end
      end
    end
  end
end
