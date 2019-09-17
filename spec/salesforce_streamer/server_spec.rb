# frozen_string_literal: true

RSpec.describe SalesforceStreamer::Server do
  let(:client) { double(authenticate!: true, subscribe: true) }
  before { allow(Restforce).to receive(:new) { client } }

  describe '.new' do
    subject { described_class.new push_topics: push_topics }

    context 'given push_topics: []' do
      let(:push_topics) { [] }

      context 'given an instance of SalesforceStreamer::Configuration' do
        let(:config) { SalesforceStreamer::Configuration.new }

        specify { expect(subject).to respond_to :run }
      end
    end
  end

  describe '#run' do
    let(:config) { SalesforceStreamer::Configuration.new }
    let(:server) { described_class.new push_topics: push_topics }

    subject { server.run }

    before { allow(EM).to receive(:run).and_yield }

    context 'given push_topics is []' do
      let(:push_topics) { [] }

      it 'no handlers subscribe' do
        expect(client).to_not receive(:subscribe)
        subject
      end
    end

    context 'given push_topics is [push_topic]' do
      let(:data) do
        {
          'handler' => 'TestHandlerClass',
          'salesforce' => {
            'name' => 'TestPushTopic',
            'query' => 'Test Query Statement'
          }
        }
      end
      let(:push_topics) { [SalesforceStreamer::PushTopic.new(data: data)] }

      it 'subscribes to topic names' do
        expect(client).to receive(:subscribe)
          .with(push_topics[0].name, replay: push_topics[0].replay)
        subject
      end

      context 'when subscriber receives a message' do
        it 'passes the message to handler_constant.call' do
          message = {
            'event' => {
              'createdDate' => '2019-07-10T16:10:16.764Z',
              'replayId' => 50,
              'type'=>'updated'
            },
            'sobject' => {
              'AccountId' => '0011m00000PU8LrAAL',
              'Id' => '0061m00000E8fSRAAZ'
            }
          }
          allow(client).to receive(:subscribe).and_yield(message)
          expect(push_topics[0].handler_constant).to receive(:call).with(message)
          subject
        end
      end
    end
  end
end
