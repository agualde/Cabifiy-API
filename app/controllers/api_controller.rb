class ApiController < ApplicationController
  
  def status
    render status: 200
  end

  def update   
    reset_data_structures 

    create_cars

    get_info

    render status: 200
  end
  
  def create
    @journey = {
      id: journey_params["id"],
      people: journey_params["people"]
    }

    find_car_for_group(@journey)

    get_info

  end


  def drop_off
    group_id = params["ID"].to_i

    generate_drop_off(group_id)

    update_car_seats_in_active_rides_hash(@found_car)

    if_group_waiting_find_them_car

    get_info

  end

  def locate
    car_id = params["ID"].to_i

    find_car_from_group(car_id)

    render json: @car
  end

  def error
    render status: 400
  end


  private

  def reset_data_structures
    @@queues = [[],[],[],[],[],[]]
    @@active_trips = []
    @@available_cars = [{},{},{},{},{},{},{}]
  end

  def create_cars
    @cars = car_params

    @cars.each do |car|
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
          journey: journey 
        }

        update_car_seats_in_active_rides_hash(car)

        @@active_trips << hash
        
        @@riding = true

        render status: 200
        break
      end
    end

    if @@riding == false

      journey_queue(@journey)

      get_info

      render status: 200
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
        @found_car = trip[group_id][:car]
        @journey = trip[group_id][:journey]
        @@active_trips.delete_if {|h| h[group_id]}
      end
    end

    @@available_cars[@found_car[:available_seats]].delete(@found_car[:id])

    @new_available_seats = @found_car[:available_seats] + @journey[:people]

    @found_car[:available_seats] = @new_available_seats

    @@available_cars[@found_car[:available_seats]][@found_car[:id]] = {
      id: @found_car[:id],
      seats: @found_car[:seats],
      available_seats: @found_car[:available_seats]
    }
  end

  def if_group_waiting_find_them_car
    queue_state = false
    @wait_list = []
       
    @@queues.each do |queue|
     if queue.first && queue.first[:people] <= @found_car[:available_seats]
        queue_state = true
        @wait_list << queue.first
      end
    end
    
    if queue_state
      
      @@queues.each do |queue|
        
        wait_times =  @wait_list.collect { |x| x[:time] }
        
        wait_times = wait_times.sort
        
        longest_time = wait_times.first 
        
        @wait_list.each do |group|
          if group[:time] == longest_time
            @longest_waiting_group_that_fits_in_car = group

            @@queues.each do |queue|
              if queue.first == @longest_waiting_group_that_fits_in_car
                queue.shift
              end
            end
          end
        end
      end
      find_car_for_group(@longest_waiting_group_that_fits_in_car)
    end
  end

  def find_car_from_group(car_id)
    @@active_trips.each do |trip|
      if trip.keys == [car_id]
        @found_car = trip[car_id][:car]
      end
    end
    
    @car = {
      id: @found_car[:id],
      seats: @found_car[:seats]
    }   
  end

  def journey_params
    params.permit!["api"]
  end

  def car_params
    params.permit!["_json"]
  end

  def get_info
    puts "---------------------"
    puts "---------------------"
    puts "---------------------"
    puts "Available cars:"
    p @@available_cars
    puts "---------------------"
    puts "---------------------"
    puts "---------------------"
    puts "Active trips:"
    p @@active_trips
    puts "---------------------"
    puts "---------------------"
    puts "---------------------"
    puts "Queues:"
    p @@queues
    puts "---------------------"
    puts "---------------------"
    puts "---------------------" 
  end
end
