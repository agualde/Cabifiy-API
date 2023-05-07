module ApiTypeValidations
  extend ActiveSupport::Concern
  include CustomRenders

  def check_incoming_cars_params
    return if journey_params["id"].is_a?(Integer) && journey_params["people"].is_a?(Integer)

    render_400
  end

  def check_journey_params
    return if journey_params["id"].is_a?(Integer) && journey_params["people"].is_a?(Integer)

    render_400
  end
  
  %w[application/json application/x-www-form-urlencoded].each do |content_type|
    define_method("ensure_#{content_type}_request") do
      return if request.headers['Content-Type'] == content_type
    
      render_400
    end
  end
end
