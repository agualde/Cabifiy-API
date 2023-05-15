# frozen_string_literal: true

module Cache
  module Instance
    def redis
      Cache::InitializerService.instance
    end
  end
end
