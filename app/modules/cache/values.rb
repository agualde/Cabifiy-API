module Cache
  module Values
    include Cache::Instance

    def active_trips
      redis.get('active_trips')
      end
  
      def available_cars
        redis.get('available_cars')
      end
  
      def journeys
        redis.get('journeys')
      end
  
      def queues
        redis.get('queues')
      end
  
      def found_car
        redis.get('found_car')
      end
  end
end
