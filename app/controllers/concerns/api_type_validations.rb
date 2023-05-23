# frozen_string_literal: true

module ApiTypeValidations
  extend ActiveSupport::Concern
  include CustomRenders

  %w[application/json application/x-www-form-urlencoded].each do |content_type|
    define_method("ensure_#{content_type}_request") do
      return if request.headers['Content-Type'] == content_type

      render_400
    end
  end
end
