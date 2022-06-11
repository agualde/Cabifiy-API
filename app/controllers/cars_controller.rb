class CarsController < ApplicationController
  # before_action :check_json
  
  def index
    @cars = Car.all 
    render json: @cars
  end

  def update
    Car.destroy_all
    Journey.destroy_all
    if Car.create(car_params) 

      puts "-------------------------------------"
      puts "-------------------------------------"
      puts "-------------------------------------"
      puts @available_cars[4].values
      puts "-------------------------------------"
      puts @available_cars[4].values.first
      puts "-------------------------------------"
      puts @available_cars[4].values.first[:id]
      puts "-------------------------------------"
      puts @available_cars[4].values.first[:available_seats]
      puts "-------------------------------------"
      puts @available_cars



      render status: 200
    end
    rescue  
      render status: 400
  end




  def create
    journey = Journey.new(id: journey_params["id"], people: journey_params["people"])
    if journey.valid?
      if journey.save
        
        render status: 200
      else
        render status: 400     
      end
    else
      render status: 400
    end
    rescue 
      render status: 400
  end

  private

    def car_params
      params.permit!["_json"]
    end
end
