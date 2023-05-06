class ApiController < ApplicationController
  include ApiTypeValidations
  include CustomRenders
  before_action :"ensure_application/json_request", only: [:update, :create]
  before_action :"ensure_application/x-www-form-urlencoded_request", only: [:drop_off, :locate]
  before_action :check_journey_params, only: [:create]

  def update
    service = Fleet::UpdateService.new(car_params)
    service.call
    render_out_data_and_status_200
    rescue => exception
    render_400
  end
  
  def create
    service = Rides::JourneyService.new(journey_params)
    service.call
    render_out_data_and_status_200
    rescue => exception
    render_400
  end

  def drop_off
    service = Rides::DropOffService.new(group_id)
    service.call
    return render status: 404 if @group_not_found
      
    render_out_data_and_status_200
  end

  def locate
    service = Rides::LocateGroupFromCarService.new(group_id)
    service.call
    rescue => exception
    render_400
  end

  private

  def journey_params
    params.permit!["api"]
  end

  def car_params
    params.permit!["_json"]
  end

  def group_id
    params["ID"].to_i
  end
end
