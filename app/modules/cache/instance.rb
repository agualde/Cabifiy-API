# frozen_string_literal: true

module Cache
  module Instance
    def redis
      Cache::RedisService.instance
    end
  end
end
