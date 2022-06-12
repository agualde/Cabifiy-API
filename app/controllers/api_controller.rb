class ApiController < ApplicationController
  
  def status
    render status: 200
  end

  def update    
    cars_to_hash

    @@queues = [[],[],[],[],[],[]]

    @@active_trips = []

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

    render status: 200
  end
  
  def create
    @journey = {
      id: journey_params["id"],
      people: journey_params["people"]
    }

    if_car_available(@journey)

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


  def drop_off
    group_id = params["ID"].to_i

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


    update_car_seats_in_active_rides_hash(@found_car)

    queue_state = false
       
      @@queues.each do |queue|
        if queue.first
          queue_state = true
        end
      end
      
      if queue_state
        @wait_list = []
        
        @@queues.each do |queue|
          if queue.first && queue.first[:people] <= @found_car[:available_seats]
            @wait_list << queue.first
          end
        end
          
          wait_times =  @wait_list.collect { |x| x[:time] }
          
          wait_times.sort
          
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
      
        if_car_available(@longest_waiting_group_that_fits_in_car)
      end

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

  def locate
    car_id = params["ID"].to_i

    @@active_trips.each do |trip|
      if trip.keys == [car_id]
        @found_car = trip[car_id][:car]
      end
    end
    
    car = {
      id: @found_car[:id],
      seats: @found_car[:seats]
    }   

    render json: car
  end

  def error
    render status: 400
  end


  private

  def journey_params
    params.permit!["api"]
  end

  def car_params
    params.permit!["_json"]
  end


  def if_car_available(journey)
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

      puts "QUEUE FORMED"
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

      render status: 200
    end
  end

  def cars_to_hash
    
    @@available_cars = [{},{},{},{},{},{},{}]

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
end
