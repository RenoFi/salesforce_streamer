RSpec.describe SalesforceStreamer::Server do
  let(:client) do
    instance_double(Restforce::Data::Client,
      authenticate!: true,
      subscribe: true,
      faye: instance_double(Faye::Client, add_extension: nil))
  end

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
    subject { server.run }

    let(:config) { SalesforceStreamer::Configuration.new }
    let(:server) { described_class.new push_topics: push_topics }

    before { allow(EM).to receive(:run).and_yield }

    context 'given push_topics is []' do
      let(:push_topics) { [] }

      it 'no handlers subscribe' do
        expect(client).not_to receive(:subscribe)
        subject
      end
    end

    context 'given push_topics is [push_topic]' do
      let(:push_topics) { [PushTopicFactory.make] }

      it 'subscribes to topic names' do
        expect(client).to receive(:subscribe)
          .with(push_topics[0].name, replay: push_topics[0].replay)
        subject
      end
    end
  end
end
