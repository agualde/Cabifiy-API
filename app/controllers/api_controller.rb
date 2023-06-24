# frozen_string_literal: true

class ApiController < ApplicationController
  include ApiTypeValidations
  include CustomRenders

  # before_action :'ensure_application/json_request', only: %i[update create]
  before_action :'ensure_application/x-www-form-urlencoded_request', only: %i[drop_off locate]

  def update
    # service = Fleet::Manage::InitializeService.new(car_params)
    # return render_400("Car parameters not valid") unless service.call

    # render_out_data_and_status_ok
    byebug
    render json: {token: 'hello from rails! ;)'}
  rescue StandardError => e
    render_400(e.message)
  end

  def create
    service = Rides::Manage::JourneyService.new(journey_params)
    return render_400("Journey parameters not valid") unless service.call

    render_out_data_and_status_ok
  rescue StandardError => e
    render_400(e.message)
  end

  def drop_off
    service = Rides::Manage::DropOffService.new(group_id)
    return render_400('Group ID PreProcessor failed') unless service.call

    render_out_data_and_status_ok
  rescue StandardError => e
    render_400(e.message)
  end

  def locate
    service = Rides::Manage::LocationService.new(group_id)
    data = service.call
    return render_400('Group ID PreProcessor failed') unless data.present?

    render json: data[:car], status: data[:status]
  rescue StandardError => e
    render_400(e.message)
  end

  private

  def journey_params
    params.require('api').permit(:id, :people)
  end

  def car_params
    params.require('_json').map do |item|
      item.permit(:id, :seats)
    end
  end

  def group_id
    params['ID'].to_i
  end
end
