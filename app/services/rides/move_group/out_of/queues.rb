# frozen_string_literal: true

module Rides
  module MoveGroup
    module OutOf
      class Queues < BaseService
        attr_accessor :group, :car

        def initialize(car, group)
          @car = car
          @group = group
          initialize_common_values
        end

        def call
          return unless group.present?

          shift_queue

          Cache::UpdateValueService.new('queues', redis_queues).call
          Execute::FindCarService.new(group.slice('id', 'people')).call
          Manage::Queues.new(car).call
        end

        private

        def shift_queue
          redis_queues.each do |queue|
            next unless queue.first == group

            car['available_seats'] = car['available_seats'] - queue.first['people']
            queue.shift
          end
        end
      end
    end
  end
end
