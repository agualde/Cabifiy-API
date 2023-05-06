module Rides
  class ManageCarUpdates
    def initialize(car, new_available_seats)
      @car = car
      @available_seats
    end

    def call
      UpdateCarSeatsInActiveCarsService.new(@found_car, new_available_seats).call
      UpdateCarSeatsInActiveTripsService.new(@found_car, new_available_seats).call
    end
  end
end