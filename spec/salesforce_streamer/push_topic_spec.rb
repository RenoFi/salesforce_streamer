RSpec.describe SalesforceStreamer::PushTopic do
  describe '#handle' do
    subject { topic.handle(message) }

    let(:topic) { PushTopicFactory.make }
    let(:message) do
      {
        'event' => {
          'createdDate' => '2019-07-10T16:10:16.764Z',
          'replayId' => 50,
          'type' => 'updated'
        },
        'sobject' => {
          'AccountId' => '0011m00000PU8LrAAL',
          'Id' => '0061m00000E8fSRAAZ'
        }
      }
    end

    specify do
      expect(TestHandlerClass).to receive(:call).with(message)
      subject
    end
  end

  describe '.new' do
    subject { PushTopicFactory.make args }

    context 'with all options' do
      let(:args) do
        {
          name: 'TestTopic',
          handler: 'TestHandlerClass',
          replay: -2,
          api_version: '29.0',
          description: 'A description',
          notify_for_fields: 'All',
          query: 'SELECT Id FROM Account'
        }
      end

      describe '#description' do
        specify { expect(subject.description).to eq 'A description' }
      end

      describe '#handler' do
        specify { expect(subject.handler).to eq TestHandlerClass }
      end

      describe '#id' do
        specify { expect(subject.id).to be_nil }
      end

      describe '#name' do
        specify { expect(subject.name).to eq 'TestTopic' }
      end

      describe '#notify_for_fields' do
        specify { expect(subject.notify_for_fields).to eq 'All' }
      end

      describe '#query' do
        specify { expect(subject.query).to eq 'SELECT Id FROM Account' }
      end

      describe '#replay' do
        specify { expect(subject.replay).to eq(-2) }
      end
    end

    context 'when data includes defined handler and query and name' do
      let(:args) do
        {
          name: 'TestTopic',
          handler: 'TestHandlerClass',
          query: 'SELECT Id FROM Account'
        }
      end

      describe '#name' do
        specify { expect(subject.name).to eq 'TestTopic' }
      end

      describe '#handler' do
        specify { expect(subject.handler).to eq TestHandlerClass }
      end

      describe '#id' do
        specify { expect(subject.id).to be_nil }
      end

      describe '#query' do
        specify { expect(subject.query).to eq 'SELECT Id FROM Account' }
      end

      describe '#replay' do
        specify { expect(subject.replay).to eq(-1) }
      end
    end
  end
end
