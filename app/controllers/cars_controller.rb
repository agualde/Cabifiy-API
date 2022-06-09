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
