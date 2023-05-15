# frozen_string_literal: true

module ApiTypeValidations
  extend ActiveSupport::Concern
  include CustomRenders

  def check_incoming_cars_params
    car_params.each do |car|
      next if car['id'].is_a?(Integer) && car['seats'].is_a?(Integer)

      render400
    end
  end

  def check_journey_params
    return if journey_params['id'].is_a?(Integer) && journey_params['people'].is_a?(Integer)

    render400
  end

  %w[application/json application/x-www-form-urlencoded].each do |content_type|
    define_method("ensure_#{content_type}_request") do
      return if request.headers['Content-Type'] == content_type

      render400
    end
  end
end
