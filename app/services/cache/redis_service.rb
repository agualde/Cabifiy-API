# frozen_string_literal: true

require 'singleton'

module Cache
  class RedisService
    include Singleton
    attr_reader :redis

    def initialize
      @redis = Redis.new
    end

    def set(key, value)
      redis.set(key, value.to_json)
    end

    def get(key)
      JSON.parse(redis.get(key))
    end
  end
end
