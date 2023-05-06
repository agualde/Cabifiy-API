module Fleet
  module Initialize
    class CarsService
      attr_accessor :cars, :invalid_car, :redis_store
      include Cache::Access

      def initialize(cars)
        @cars = cars
        @invalid_car = false
        @redis_store = available_cars
      end

      def call
        cars.each do |car|
          invalid_car = true unless car_is_valid(car)
            
          put_car_in_available_cars(car)
        end
      end

      def failed?
        invalid_car
      end

      private

      def car_is_valid(car)
        return false unless car["id"].is_a?(Integer) && car["seats"].is_a?(Integer) 
          
        
        true
      end
    
      def put_car_in_available_cars(car)
        for i in 1..6
          if car["seats"] == i
        
            redis_store[i][car["id"]] = {
              id: car["id"],
              seats: car["seats"],
              available_seats: car["seats"]
            }
    
            redis.set("available_cars", redis_store)
          end
        end
      end
    end
  end
end
