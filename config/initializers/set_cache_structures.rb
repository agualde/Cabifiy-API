# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  service = Cache::ResetStructuresService.new
  service.call
end
