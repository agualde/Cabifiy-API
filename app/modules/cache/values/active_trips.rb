# frozen_string_literal: true

module Cache
  module Values
    module ActiveTrips
      include Cache::Instance

      def active_trips
        redis.get('active_trips')
      end
    end
  end
end
