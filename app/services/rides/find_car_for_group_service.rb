module Rides
  class FindCarForGroupService
    attr_accessor :journey, :cars, :trips
    include Cache::Instance
    include Cache::Values

    def initialize(journey)
      @journey = journey
      @cars = available_cars
      @trips = active_trips
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
          cars[i].delete(car_id)
  
          new_available_seats = car["available_seats"] - journey[:people]
          car[:available_seats] = new_available_seats
  
          cars[car[:available_seats]][car[:id]] = {
            id: car['id'],
            seats: car['seats'],
            available_seats: car[:available_seats]
          }

          hash = {}

          hash[journey[:id]] = {
            car: car, 
            journey: {
              id:journey[:id], 
              people: journey[:people]
            }
          }

          Rides::UpdateCarSeatsInActiveRidesService.new(car, new_available_seats).call

          trips << hash
          redis.set("available_cars", cars)
          redis.set("active_trips", trips)
          @riding = true
          break

        end
      end

      journey_queue(journey) if @riding == false
    end
  
    def journey_queue(journey)
      for i in 1..6
        if journey[:people] == i
          queues[i -1] << {
              id: journey[:id],
              people: journey[:people],
              time: Time.now
            }
        end
      end
    end
  end
end