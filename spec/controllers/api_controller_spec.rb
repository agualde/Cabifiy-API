# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiController do
  describe 'POST #update' do
    let(:valid_params) do
      [{
        'id' => 1,
        'seats' => 3
      }]
    end

    before do
      request.headers['CONTENT_TYPE'] = 'application/json'
      allow(Fleet::Manage::InitializeService).to receive(:new).and_return(service)
      allow(service).to receive(:call)
    end

    let(:service) { instance_double(Fleet::Manage::InitializeService) }

    it 'calls the UpdateService and renders success' do
      post :update, params: { _json: valid_params }

      expect(response).to have_http_status(:ok)
      expect(Fleet::Manage::InitializeService).to have_received(:new).with(valid_params)
      expect(service).to have_received(:call)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        'id' => 1,
        'people' => 3
      }
    end

    before do
      request.headers['CONTENT_TYPE'] = 'application/json'
      allow(Rides::Prepare::JourneyService).to receive(:new).and_return(service)
      allow(service).to receive(:call)
    end

    let(:service) { instance_double(Rides::Prepare::JourneyService) }

    it 'calls the JourneyService and renders success' do
      post :create, params: { api: valid_params }

      expect(response).to have_http_status(:ok)
      expect(Rides::Prepare::JourneyService).to have_received(:new).with(valid_params)
      expect(service).to have_received(:call)
    end
  end

  describe 'POST #drop_off' do
    let(:group_id) { 1 }

    before do
      request.headers['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
      allow(Rides::Manage::DropOffService).to receive(:new).and_return(service)
      allow(service).to receive(:call).and_return(true)
    end

    let(:service) { instance_double(Rides::Manage::DropOffService) }

    it 'calls the DropOffService and renders success' do
      post :drop_off, params: { ID: group_id }

      expect(response).to have_http_status(:ok)
      expect(Rides::Manage::DropOffService).to have_received(:new).with(group_id)
      expect(service).to have_received(:call)
    end
  end

  describe 'POST #locate' do
    let(:group_id) { 1 }
    let(:data) { { car: 'some car', status: 200 } }

    before do
      request.headers['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
      allow(Rides::LocateGroupFromCarService).to receive(:new).and_return(service)
      allow(service).to receive(:call).and_return(data)
    end

    let(:service) { instance_double(Rides::LocateGroupFromCarService) }

    it 'calls the LocateGroupFromCarService and renders success' do
      post :locate, params: { ID: group_id }

      expect(response).to have_http_status(:ok)
      expect(Rides::LocateGroupFromCarService).to have_received(:new).with(group_id)
      expect(service).to have_received(:call)
    end
  end
end
