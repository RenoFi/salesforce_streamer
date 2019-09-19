# frozen_string_literal: true

RSpec.describe SalesforceStreamer::ReplayPersistence do
  describe '.record' do
    subject { described_class.record key, value }

    context 'key: nil, value: nil' do
      let(:key) { nil }
      let(:value) { nil }

      specify { expect(subject).to eq value }
    end

    context 'key: "key", value: "123"' do
      let(:key) { 'key' }
      let(:value) { '123' }

      specify { expect(subject).to eq 1 }
    end
  end

  describe 'retrieve' do
    subject { described_class.retrieve key }

    context 'key without values' do
      let(:key) { 'unknown' }

      specify { expect(subject).to eq nil }
    end

    context 'after storing 3, 16, 8' do
      let(:key) { 'anotherkey' }

      before { [3, 16, 8].each { |value| described_class.record key, value } }

      specify { expect(subject).to eq 16 }
    end
  end
end
