# frozen_string_literal: true

RSpec.describe SalesforceStreamer::Launcher do
  let(:server) { double(run: true, 'push_topics=' => true) }
  let(:manager) { double(run: true, push_topics: []) }

  before do
    allow(SalesforceStreamer::Server).to receive(:new) { server }
    allow(SalesforceStreamer::TopicManager).to receive(:new) { manager }
  end

  context 'loading push topics from :test' do
    let(:path) { './spec/fixtures/configuration/config.yml' }
    let(:config) { SalesforceStreamer::Configuration.new }

    before do
      config.environment = :test
      config.config_file = path
      config.require_path = nil
    end

    describe '.new' do
      subject { described_class.new config: config }

      specify { expect(subject).to respond_to :run }

      it 'calls TopicManager.new with push_topics loaded from config YAML' do
        expect(SalesforceStreamer::TopicManager)
          .to receive(:new)
          .with(push_topics: kind_of(Array), config: config)
        subject
      end
    end

    describe '#run' do
      let(:launcher) { described_class.new config: config }

      subject { launcher.run }

      it 'calls TopicManager#run' do
        expect(manager).to receive :run
        subject
      end

      it 'calls Server#push_topics=' do
        expect(server).to receive(:push_topics=).with(kind_of(Array))
        subject
      end

      it 'calls Server#run' do
        expect(server).to receive :run
        subject
      end
    end
  end
end
