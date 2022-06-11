class ApiController < ApplicationController
  
  def status
    render status: 200
  end

  def update    
    cars_to_hash
    @@queues = [[],[],[],[],[],[]]
    @@active_trips = {}
    render status: 200
  end
  
  def create
    
    @journey = journey_params

    def if_car_available(journey)

      for i in (journey["people"]..6)

        if @@available_cars[i - 1].present? 

          car = @@available_cars[i - 1].first

          @@available_cars[i - 1].delete(car[0])

          car[1][:available_seats] = car[1][:available_seats] - journey["people"]

            if car[1][:available_seats] > 0  
              @@available_cars[car[1][:available_seats] - 1][car[1][:id]] = {
                id: car[1][:id],
                seats: car[1][:seats],
                available_seats: car[1][:available_seats]
              }
            end

          @@active_trips[journey["id"]] = car[1]
      
          p @@active_trips

          raise

        # else

        # journey_queue(@journey)

        end

      end

    end

    if_car_available(@journey)

    render status: 200
    
  end


  def drop_off

  end

  def locate
    render json: @@active_trips[params["ID"].to_i]
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


  def cars_to_hash
    
    @@available_cars = [{},{},{},{},{},{}]

    @cars = car_params

    @cars.each do |car|
      if car["seats"] == 1
        @@available_cars[0][car["id"]] = {
            id: car["id"],
            seats: car["seats"],
            available_seats: car["seats"]
          }
      elsif car["seats"] == 2
        @@available_cars[1][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 3
        @@available_cars[2][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 4
        @@available_cars[3][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 5
        @@available_cars[4][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      elsif car["seats"] == 6
        @@available_cars[5][car["id"]] = {
          id: car["id"],
          seats: car["seats"],
          available_seats: car["seats"]
        }
      end
    end
  end

  def journey_queue(journey)
    if journey["people"] == 1
      @@queues[0] << {
          id: journey["id"],
          people: journey["people"],
          time: Time.now
        }
    elsif journey["people"] == 2
      @@queues[1] << {
        id: journey["id"],
        people: journey["people"],
        time: Time.now
      }
    elsif journey["people"] == 3
      @@queues[2] << {
        id: journey["id"],
        people: journey["people"],
        time: Time.now
      }
    elsif journey["people"] == 4
      @@queues[3] << {
        id: journey["id"],
        people: journey["people"],
        time: Time.now
      }
    elsif journey["people"] == 5
      @@queues[4] << {
        id: journey["id"],
        people: journey["people"],
        time: Time.now
      }
    elsif journey["people"] == 6
      @@queues[5] << {
        id: journey["id"],
        people: journey["people"],
        time: Time.now
      }
    end
  end
end
