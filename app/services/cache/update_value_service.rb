# frozen_string_literal: true

module Cache
  class UpdateValueService
    include Cache::Instance

    attr_accessor :key, :attribute

    def initialize(key, attribute)
      @key = key
      @attribute = attribute
    end

    def call
      redis.set(key, attribute)
    end
  end
end
