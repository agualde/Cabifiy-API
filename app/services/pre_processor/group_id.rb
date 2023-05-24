# frozen_string_literal: true

module PreProcessor
  class GroupId
    attr_accessor :group_id

    def initialize(group_id)
      @group_id = group_id
    end

    def call
      id_uniqueness_check
    end

    def id_uniqueness_check
      return true if group_id.present? && group_id.is_a?(Integer)

      false
    end

    alias valid? call
  end
end
