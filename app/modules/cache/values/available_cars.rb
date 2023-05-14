# frozen_string_literal: true

module Cache
  module Values
    module AvailableCars
      include Cache::Instance

      def available_cars
        redis.get('available_cars')
      end
    end
  end
end
