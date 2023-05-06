module Rides
  class LocateGroupFromCarService
    attr_accessor :group
    include Cache::Values

    def initialize(group)
      @group = group
    end

    def call
      find_car_from_group

      if @car
        render json: @car
      elsif @group_waiting_in_queue_to_be_processed
        render status: 204
      elsif @car.nil?
        render status: 404
      end
    end

    private

    def find_car_from_group
      @group_waiting_in_queue_to_be_processed = false
      @@active_trips.select do |trip|
        if trip[group_id]
          @@found_car = trip[group_id][:car]
          @car = {
            id: @@found_car[:id],
            seats: @@found_car[:seats]
          }
        end
        if trip[group_id].nil?
          if @@journeys[group_id]
            @group_waiting_in_queue_to_be_processed = true
          end
        end
      end
    end
  end
end
