class ApiController < ApplicationController
  
  def status
    render status: 200
  end

  def update    
    cars_to_hash

    @@queues = [[],[],[],[],[],[]]

    @@active_trips = []

    render status: 200
  end
  
  def create
    @journey = {
      id: journey_params["id"],
      people: journey_params["people"]
    }

    if_car_available(@journey)
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

    @found_car[:available_seats] = @found_car[:available_seats] + @journey[:people]

    @@available_cars[@found_car[:available_seats]][@found_car[:id]] = {
      id: @found_car[:id],
      seats: @found_car[:seats],
      available_seats: @found_car[:available_seats]
    }

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

        car = @@available_cars[i].first

        @@available_cars[i].delete(car[0])

        car[1][:available_seats] = car[1][:available_seats] - journey[:people]

        @@available_cars[car[1][:available_seats]][car[1][:id]] = {
          id: car[1][:id],
          seats: car[1][:seats],
          available_seats: car[1][:available_seats]
        }

        hash = {}

        hash[journey[:id]] = {
          car: car[1],
          journey: journey 
        }

        @@active_trips << hash
        
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
      if car["seats"] == 1
        @@available_cars[1][car["id"]] = {
            id: car["id"],
            seats: car["seats"],
            available_seats: car["seats"]
          }
      elsif car["seats"] == 2
        @@available_cars[2][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 3
        @@available_cars[3][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 4
        @@available_cars[4][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 5
        @@available_cars[5][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 6
        @@available_cars[6][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      end
    end
  end

  def journey_queue(journey)
    if journey[:people] == 1
      @@queues[0] << {
          id: journey[:id],
          people: journey[:people],
          time: Time.now
        }
    elsif journey[:people] == 2
      @@queues[1] << {
        id: journey[:id],
        people: journey[:people],
        time: Time.now
      }
    elsif journey[:people] == 3
      @@queues[2] << {
        id: journey[:id],
        people: journey[:people],
        time: Time.now
      }
    elsif journey[:people] == 4
      @@queues[3] << {
        id: journey[:id],
        people: journey[:people],
        time: Time.now
      }
    elsif journey[:people] == 5
      @@queues[4] << {
        id: journey[:id],
        people: journey[:people],
        time: Time.now
      }
    elsif journey[:people] == 6
      @@queues[5] << {
        id: journey[:id],
        people: journey[:people],
        time: Time.now
      }
    end
  end
end
