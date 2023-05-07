module Rides
  class FindCarForGroupService
    attr_accessor :journey, :cars, :riding
    include Cache::Values::AvailableCars

    def initialize(journey)
      @journey = journey

      @cars = available_cars

      @riding = false
    end

    def call
      find_car_for_group
    end

    def find_car_for_group

      for i in (journey[:people]..6)

        if cars[i].present? 
          car_id = cars[i].first[0]
          car = cars[i].first[1]
          
          new_available_seats = car["available_seats"] - journey[:people]

          PutGroupInActiveTripsService.new(car, journey).call
          SeatsUpdateService.new(car, new_available_seats, journey).call

          @riding = true
          break
        end
      end

      JourneyQueueService.new(@journey).call if @riding == false
    end
  end
end
