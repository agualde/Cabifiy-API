# frozen_string_literal: true

class ApiController < ApplicationController
  include ApiTypeValidations
  include CustomRenders

  before_action :'ensure_application/json_request', only: %i[update create]
  before_action :'ensure_application/x-www-form-urlencoded_request', only: %i[drop_off locate]

  def update
    service = Fleet::Manage::InitializeService.new(car_params)
    return render_400 unless service.call

    render_out_data_and_status_ok
  rescue StandardError
    render_400
  end

  def create
    service = Rides::Manage::JourneyService.new(journey_params)
    return render_400 unless service.call

    render_out_data_and_status_ok
  rescue StandardError
    render_400
  end

  def drop_off
    service = Rides::Manage::DropOffService.new(group_id)
    return render status: 404 unless service.call

    render_out_data_and_status_ok
  rescue StandardError
    render_400
  end

  def locate
    service = Rides::Manage::LocationService.new(group_id)
    data = service.call
    return render status: 400 unless data.present?

    render json: data[:car], status: data[:status]
  rescue StandardError
    render_400
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
