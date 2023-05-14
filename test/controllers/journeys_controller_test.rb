# frozen_string_literal: true

require 'test_helper'

class JourneysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @journey = journeys(:one)
  end

  test 'should get index' do
    get journeys_url, as: :json
    assert_response :success
  end

  test 'should create journey' do
    assert_difference('Journey.count') do
      post journeys_url, params: { journey: { people: @journey.people } }, as: :json
    end

    assert_response 201
  end

  test 'should show journey' do
    get journey_url(@journey), as: :json
    assert_response :success
  end

  test 'should update journey' do
    patch journey_url(@journey), params: { journey: { people: @journey.people } }, as: :json
    assert_response 200
  end

  test 'should destroy journey' do
    assert_difference('Journey.count', -1) do
      delete journey_url(@journey), as: :json
    end

    assert_response 204
  end
end
