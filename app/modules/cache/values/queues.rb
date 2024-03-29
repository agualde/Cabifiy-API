# frozen_string_literal: true

module Cache
  module Values
    module Queues
      include Cache::Instance

      def queues
        redis.get('queues')
      end
    end
  end
end
