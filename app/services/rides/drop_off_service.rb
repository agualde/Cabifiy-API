module Rides
  class DropOffService
    attr_accessor :group
    include RedisInstance
    
    def initialize(group)
      @group = group
      @active_trips = redis.get('active_trips')
    end

    def call
      generate_drop_off(group_id)

      @running = true
  
      while @running 
        if_group_waiting_find_them_car
        update_found_car
      end
    end

    private

    def generate_drop_off(group_id)
      active_trips.each do |trip|
        if trip.keys == [group_id]
          @@found_car = trip[group_id][:car]
          @journey = trip[group_id][:journey]
          @@active_trips.delete_if {|h| h[group_id]}
          if @@journeys[group_id]
            @@journeys.delete(group_id)
          end
        end
      end
      @group_not_found = false
      if @@found_car.nil?
        @group_not_found = true
      elsif @journey.nil?
        @group_not_found = true
      else
        @@available_cars[@@found_car[:available_seats]].delete(@@found_car[:id])
    
        @new_available_seats = @@found_car[:available_seats] + @journey[:people]
        @@found_car[:available_seats] = @new_available_seats
  
        @@available_cars[@@found_car[:available_seats]][@@found_car[:id]] = {
          id: @@found_car[:id],
          seats: @@found_car[:seats],
          available_seats: @@found_car[:available_seats]
        }
        update_car_seats_in_active_rides_hash(@@found_car)
      end
    end

    def update_car_seats_in_active_rides_hash(car)
      active_trips.each do |active_trip_hash|
        if active_trip_hash.values[0][:car][:id] == car[:id]
          active_trip_hash.values[0][:car][:available_seats] = @new_available_seats
        end
      end
      redis.set("active_trips", active_trips.to_json)
    end
  end
end
