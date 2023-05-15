# frozen_string_literal: true

RSpec.shared_context 'initialize common structures' do
  let(:available_cars) do
    [
      {},
      {},
      {},
      {},
      {},
      {},
      {}
    ]
  end

  let(:journeys) { {} }

  let(:active_trips) { [] }

  let(:queues) do
    [
      [],
      [],
      [],
      [],
      [],
      []
    ]
  end
end
