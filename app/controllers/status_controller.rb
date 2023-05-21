# frozen_string_literal: true

class StatusController < ApplicationController
  def status
    render status: 200
  end
end
