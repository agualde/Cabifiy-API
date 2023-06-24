# frozen_string_literal: true

module PreProcessor
  class Journey
    attr_accessor :group

    def initialize(group)
      @group = group
    end

    def call
      people_range_check && id_check
    end

    def people_range_check
      people = group['people']
      return true if people.present? && people.is_a?(Integer) && people.between?(1, 6)

      false
    end

    def id_check
      id = group['id']
      return true if id.present? && id.is_a?(Integer)

      false
    end

    alias valid? call
  end
end
