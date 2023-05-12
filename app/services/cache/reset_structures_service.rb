# frozen_string_literal: true

module Cache
  class ResetStructuresService
    include Cache::Instance

    def call
      %w[available_cars queues active_trips journeys found_car].each do |key|
        redis.set(key, nil)
      end

      redis.set('available_cars', [{}, {}, {}, {}, {}, {}, {}])
      redis.set('queues', [[], [], [], [], [], []])
      redis.set('active_trips', [])
      redis.set('journeys', {})
      redis.set('found_car', nil)
    end
  end
end
