module Rides
  class DropOffService
    attr_accessor :group, :trips, :group_not_found, :running, :queue_state, :wait_list, :redis_queues, :redis_journeys, :cars
    include Cache::Access
    
    def initialize(group)
      @group = group.to_s
      @trips = active_trips 
      @redis_journeys = journeys
      @redis_queues = queues
      @running = true
      @group_not_found = false
      @queue_state = false
      @found_car = nil
      @cars = available_cars
      @wait_list = []
    end

    def call
      generate_drop_off

      while @running 
        if_group_waiting_find_them_car
        update_found_car
      end
    end

    def group_not_found?
      group_not_found
    end

    private

    def generate_drop_off
      trips.each do |trip|
        if trip.keys == [group]
          @found_car = trip[group]['car']
          @journey = trip[group]['journey']
          trips.delete_if {|h| h[group]}

          if redis_journeys[group]
            redis_journeys.delete(group)
          end
        end
      end

      if @found_car.nil?
        @group_not_found = true
      elsif @journey.nil?
        @group_not_found = true
      else

        cars[@found_car['available_seats']].delete(@found_car['id'].to_s)    


        new_available_seats = @found_car['available_seats'] + @journey['people']
        @found_car['available_seats'] = new_available_seats

        cars[@found_car['available_seats']][@found_car['id']] = {
          id: @found_car['id'],
          seats: @found_car['seats'],
          available_seats: @found_car['available_seats']
        }

        ManageCarUpdates.new(@found_car, new_available_seats).call

        redis.set('available_cars', cars)
        redis.set('journeys', redis_journeys)
        redis.set('active_trips', trips)
      end
    end

    def if_group_waiting_find_them_car    
      check_queue
      if queue_state 
        wait_times =  wait_list.collect { |x| x[:time] }
        longest_time = wait_times.sort.first 
        
        @wait_list.each do |group|
          
          if group[:time] == longest_time
            @longest_waiting_group_that_fits_in_car = group
          end
  
          redis_queues.each do |queue|
            if queue.first == @longest_waiting_group_that_fits_in_car
              queue.shift
            end
          end
        end

        FindCarForGroupService.new(longest_waiting_group_that_fits_in_car).call
      end
    end
  
    def update_found_car
      trips.each do |trip| 
        if @longest_waiting_group_that_fits_in_car
          if trip[@longest_waiting_group_that_fits_in_car[:id]]
            @@found_car = trip[@longest_waiting_group_that_fits_in_car[:id]][:car]
          end
        end
      end
    end

    def check_queue    
      redis_queues.each do |queue|
        unless @found_car.nil?
          if queue.first && queue.first[:people] <= @found_car[:available_seats]
            @queue_state = true
            wait_list << queue.first
          end
        end
      end

      if wait_list.empty?
        @running = false
      end
    end
  end
end
