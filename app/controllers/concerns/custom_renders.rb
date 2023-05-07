module CustomRenders
  extend ActiveSupport::Concern
  include Cache::Values::All

  def render_out_data_and_status_200
    render  json: { available_cars: available_cars, journeys: journeys, active_trips: active_trips, queues: queues }, status: 200
  end

  def render_400
    render status: 400
  end
end
