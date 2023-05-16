# frozen_string_literal: true

module Cache
  module Values
    module All
      include Cache::Values::AvailableCars
      include Cache::Values::ActiveTrips
      include Cache::Values::Journeys
      include Cache::Values::Queues
    end
  end
end
