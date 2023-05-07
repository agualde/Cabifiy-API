module Cache
  module Values
    module FoundCar
    include Cache::Instance

      def found_car
        redis.get('found_car')
      end
    end 
  end
end
