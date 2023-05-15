# frozen_string_literal: true

class ApiController < ApplicationController
  include ApiTypeValidations
  include CustomRenders

  before_action :'ensure_application/json_request', only: %i[update create]
  before_action :'ensure_application/x-www-form-urlencoded_request', only: %i[drop_off locate]
  before_action :check_journey_params, only: [:create]
  before_action :check_incoming_cars_params, only: [:update]

  def update
    byebug
    service = Fleet::Manage::InitializeService.new(car_params)
    service.call
    render_out_data_and_status_ok
  rescue StandardError
    render400
  end

  def create
    service = Rides::Prepare::JourneyService.new(journey_params)
    service.call
    render_out_data_and_status_ok
  rescue StandardError
    render400
  end

  def drop_off
    service = Rides::Manage::DropOffService.new(group_id)
    return render status: 404 unless service.call

    render_out_data_and_status_ok
  rescue StandardError
    render400
  end

  def locate
    service = Rides::LocateGroupFromCarService.new(group_id)
    data = service.call
    render json: data[:car], status: data[:status]
  rescue StandardError
    render400
  end

  private

  def journey_params
    params.permit!['api']
  end

  def car_params
    params.permit!['_json']
  end

  def group_id
    params['ID'].to_i
  end
end
