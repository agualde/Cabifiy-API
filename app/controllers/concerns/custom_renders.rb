# frozen_string_literal: true

module CustomRenders
  extend ActiveSupport::Concern
  include Cache::Values::All

  def render_out_data_and_status_ok
    render json: { available_cars: available_cars, journeys: journeys, active_trips: active_trips, queues: queues },
           status: 200
  end

  def render400
    render status: 400
  end
end
