class ApiController < ApplicationController
  def status
    render status: 200
  end

  def update  
    if request.content_type == "application/json"
      begin
        reset_data_structures 
        create_cars
        if @all_cars_valid
          render_out_data_and_status_200
        else
          render_400_status
        end
      rescue => exception
        render_400_status
      end
    else
      render_400_status
    end
  end
  
  def create
    if request.content_type == "application/json" && journey_params["id"].is_a?(Integer) && journey_params["people"].is_a?(Integer)
        hash = {
        id: journey_params["id"],
        people: journey_params["people"]
      }
      find_car_for_group(hash)

      @@journeys[hash[:id]] = {
        id: hash[:id],
        people: hash[:people]
      }
      render_out_data_and_status_200
    else
      render_400_status
    end
  end

  def drop_off
    service = Rides::DropOffService.new(group_id)
    return render status: 404 unless service.call

    render_out_data_and_status_ok
  rescue StandardError
    render400
  end

  def locate
    if request.content_type == "application/x-www-form-urlencoded"
      begin
        group_id = params["ID"].to_i
        find_car_from_group(group_id)
        if @car
          render json: @car
        elsif @group_waiting_in_queue_to_be_processed
          render status: 204
        elsif @car.nil?
          render status: 404
        end
      rescue => exception
        render status: 400
      end
    else
      render status: 400
    end
  end

  def error
    render status: 400
  end

  private

  def reset_data_structures
    @@available_cars = [{},{},{},{},{},{},{}]
    @@queues = [[],[],[],[],[],[]]
    @@active_trips = []
    @@journeys = {}
    @@found_car = nil
  end

  def create_cars
    @cars = car_params
    @all_cars_valid = true
    @cars.each do |car|
      if car_is_valid(car)
        put_car_in_available_cars(car)
      else
        @all_cars_valid = false
      end 
    end
  end

  def car_is_valid(car)
    if car["id"].is_a?(Integer) && car["seats"].is_a?(Integer) 
      return true 
    else
      return false
    end
  end

  def put_car_in_available_cars(car)
    for i in 1..6
      if car["seats"] == i
        @@available_cars[i][car["id"]] = {
            id: car["id"],
            seats: car["seats"],
            available_seats: car["seats"]
          }
      end
    end
  end

  def find_car_for_group(journey)
    @@riding = false
    for i in (journey[:people]..6)
      if @@available_cars[i].present? 
        car = @@available_cars[i].first[1]
        car_id = @@available_cars[i].first[0]

        @@available_cars[i].delete(car_id)
        
        @new_available_seats = car[:available_seats] - journey[:people]
        car[:available_seats] = @new_available_seats

        @@available_cars[car[:available_seats]][car[:id]] = {
          id: car[:id],
          seats: car[:seats],
          available_seats: car[:available_seats]
        }
        hash = {}
        hash[journey[:id]] = {
          car: car, 
          journey: {
            id:journey[:id], 
            people: journey[:people]
          }
        }
        update_car_seats_in_active_rides_hash(car)
        @@active_trips << hash
        @@riding = true
        break
      end
    end
    if @@riding == false
      journey_queue(journey)
    end
  end

  def journey_queue(journey)
    for i in 1..6
      if journey[:people] == i
        @@queues[i -1] << {
            id: journey[:id],
            people: journey[:people],
            time: Time.now
          }
      end
    end
  end

  def update_car_seats_in_active_rides_hash(car)
    @@active_trips.each do |active_trip_hash|
      if active_trip_hash.values[0][:car][:id] == car[:id]
        active_trip_hash.values[0][:car][:available_seats] = @new_available_seats
      end
    end
  end

  def generate_drop_off(group_id)
    @@active_trips.each do |trip|
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
      update_car_seats_in_active_rides_hash(@@found_car)
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

  def find_car_from_group(group_id)
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

  def render_out_data_and_status_200
    render json: { available_cars: @@available_cars, journeys: @@journeys, active_trips: @@active_trips, queues: @@queues }, status: 200
  end

  def render_400_status
    render status: 400
  end

  def journey_params
    params.permit!["api"]
  end

  def car_params
    params.permit!["_json"]
  end
end