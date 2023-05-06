module Rides
  class DropOffService
    attr_accessor :group
    include Cache::Access
    
    def initialize(group)
      @group = group
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
        UpdateCarSeatsInActiveRidesService.new(car, new_available_seats).call
      end
    end

    def if_group_waiting_find_them_car    
      check_queue
      if @queue_state 
        wait_times =  @wait_list.collect { |x| x[:time] }
        longest_time = wait_times.sort.first 
        
        @wait_list.each do |group|
          
          if group[:time] == longest_time
            @longest_waiting_group_that_fits_in_car = group
          end
  
          @@queues.each do |queue|
            if queue.first == @longest_waiting_group_that_fits_in_car
              queue.shift
            end
          end
        end
        find_car_for_group(@longest_waiting_group_that_fits_in_car)
      end
    end
  
    def update_found_car
      @@active_trips.each do |trip| 
        if @longest_waiting_group_that_fits_in_car
          if trip[@longest_waiting_group_that_fits_in_car[:id]]
            @@found_car = trip[@longest_waiting_group_that_fits_in_car[:id]][:car]
          end
        end
      end
    end

    def check_queue    
      @queue_state = false
      @wait_list = []
      @@queues.each do |queue|
        unless @@found_car.nil?
          if queue.first && queue.first[:people] <= @@found_car[:available_seats]
            @queue_state = true
            @wait_list << queue.first
          end
        end
      end
      if @wait_list.empty?
        @running = false
      end
    end
  end
end
