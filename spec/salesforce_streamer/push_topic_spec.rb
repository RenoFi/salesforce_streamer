# frozen_string_literal: true

RSpec.describe SalesforceStreamer::PushTopic do
  describe '.new' do
    subject { described_class.new data: data }

    context 'when data is {}' do
      let(:data) { {} }

      specify { expect { subject }.to raise_exception { SalesforceStreamer::PushTopicHandlerMissingError } }
    end

    context 'with data' do
      let(:data) do
        {
          'handler' => 'TestHandlerClass',
          'replay' => '-2',
          'salesforce' => {
            'name' => 'UniqueName',
            'api_version' => '29.0',
            'description' => 'A description',
            'notify_for_fields' => 'All',
            'query' => 'SELECT Id FROM Account'
          }
        }
      end

      describe '#description' do
        specify { expect(subject.description).to eq 'A description' }
      end

      describe '#handler' do
        specify { expect(subject.handler).to eq 'TestHandlerClass' }
      end

      describe '#id' do
        specify { expect(subject.id).to eq nil }
      end

      describe '#name' do
        specify { expect(subject.name).to eq 'UniqueName' }
      end

      describe '#notify_for_fields' do
        specify { expect(subject.notify_for_fields).to eq 'All' }
      end

      describe '#query' do
        specify { expect(subject.query).to eq 'SELECT Id FROM Account' }
      end

      describe '#replay' do
        specify { expect(subject.replay).to eq -2 }
      end
    end

    context 'when data includes defined handler and query and name' do
      let(:data) do
        {
          'handler' => 'TestHandlerClass',
          'salesforce' => {
            'name' => 'UniqueName',
            'query' => 'SELECT Id FROM Account'
          }
        }
      end

      describe '#name' do
        specify { expect(subject.name).to eq 'UniqueName' }
      end

      describe '#handler' do
        specify { expect(subject.handler).to eq 'TestHandlerClass' }
      end

      describe '#id' do
        specify { expect(subject.id).to eq nil }
      end

      describe '#query' do
        specify { expect(subject.query).to eq 'SELECT Id FROM Account' }
      end

      describe '#replay' do
        specify { expect(subject.replay).to eq -1 }
      end
    end
  end
end
