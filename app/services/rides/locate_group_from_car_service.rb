module Rides
  class LocateGroupFromCarService
    attr_accessor :group, :trips, :redis_journeys, :group_waiting, :car
    include Cache::Values

    def initialize(group)
      @group = group.to_s
      @trips = active_trips
      @redis_journeys = journeys
      @group_waiting = false
      @car = {}
    end

    def call
      find_car_from_group
      if @car.present?
         { car: @car, status: :ok}
      elsif group_waiting
         { car: nil, status: :no_content}
      else car.nil?
         { car: nil, status: 404}
      end
    end

    private

    def find_car_from_group
      trips.each do |trip|
        if trip[group.to_s]

          found_car = trip[group]['car']

          @car = {
            id: found_car['id'],
            seats: found_car['seats']
          }
        end

        if trip[group].nil?
          group_waiting = true if redis_journeys[group]
        end

        @car
      end
    end
  end
end
