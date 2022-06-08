class JourneysController < ApplicationController

  # GET /journeys
  def index
    @journeys = Journey.all

    render json: @journeys, only: [:id, :people]
  end

  # POST /journeys
  def create
   Journey.destroy_all 
    if Journey.create(journey_params)
      render status: 200
    end
  end


  private
    def journey_params
      params.permit!["_json"]
    end
end
