class ApiController < ApplicationController

  def index_cars
    @cars = Car.all 
    render json: @cars, only: [:id, :seats]
  end

  # GET /journeys
  def index_journeys
    @journeys = Journey.all

    render json: @journeys, only: [:id, :people]
  end

  def update    
    test_1 = {}
    test_2 = {}
    test_3 = {}
    test_4 = {}
    test_5 = {}
    test_6 = {}
    
    @avalaible_cars = []

    @cars = car_params

    @cars.each do |car|
      if car["seats"] == 1
        test_1[car["id"]] = car
      elsif car["seats"] == 2
        test_2[car["id"]] = car
      elsif car["seats"] == 3
        test_3[car["id"]] = car
      elsif car["seats"] == 4
        test_4[car["id"]] = car
      elsif car["seats"] == 5
        test_5[car["id"]] = car
      elsif car["seats"] == 6
        test_6[car["id"]] = car
      end
    end
    
    @avalaible_cars.push(test_1, test_2, test_3, test_4, test_5, test_6)

    puts @avalaible_cars[3].values.first["seats"]

    puts @avalaible_cars

    render status: 200
  end

  def create
    @journey = journey_params

  end


  def drop_off
    something something

    journey = Journey.find
    journey.destroy

    something something
  end

  def locate
    something something

    car_id = 
    car = Car.find(car_id)
    return car
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
end
