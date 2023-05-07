module Cache
  module Values
    module Journeys
    include Cache::Instance

      def journeys
        redis.get('journeys')
      end
    end 
  end
end
