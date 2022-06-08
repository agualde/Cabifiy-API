class CarsController < ApplicationController
  # before_action :check_json
  
  def index
    @cars = Car.all 
    render json: @cars, only: [:id, :seats]
  end


  def update
    Car.destroy_all
    if Car.create(car_params) 
      render status: 200
    end
    rescue  
      render status: 400
  end

  def error
    render status: 400
  end

  private

    def car_params
      params.permit!["_json"]
    end
end
