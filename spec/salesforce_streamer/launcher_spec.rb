RSpec.describe SalesforceStreamer::Launcher do
  let(:server) { instance_double(SalesforceStreamer::Server, :run => true, "push_topics=" => true) }
  let(:manager) { instance_double(SalesforceStreamer::SalesforceTopicManager, upsert_topics!: true, push_topics: []) }

  before do
    allow(SalesforceStreamer::Server).to receive(:new) { server }
    allow(SalesforceStreamer::SalesforceTopicManager).to receive(:new) { manager }
  end

  context "when loading push topics from :test" do
    let(:path) { "./spec/fixtures/configuration/config.yml" }
    let(:config) { SalesforceStreamer::Configuration.instance }

    before do
      config.environment = :test
      config.config_file = path
      config.require_path = nil
    end

    describe ".new" do
      subject { described_class.new }

      specify { expect(subject).to respond_to :run }

      it "calls SalesforceTopicManager.new with push_topics loaded from config YAML" do
        expect(SalesforceStreamer::SalesforceTopicManager)
          .to receive(:new)
          .with(push_topics: kind_of(Array))
        subject
      end
    end

    describe "#run" do
      subject { launcher.run }

      let(:launcher) { described_class.new }

      it "calls SalesforceTopicManager#run" do
        expect(manager).to receive :upsert_topics!
        subject
      end

      it "calls Server#push_topics=" do
        expect(server).to receive(:push_topics=).with(kind_of(Array))
        subject
      end

      it "calls Server#run" do
        expect(server).to receive :run
        subject
      end
    end
  end
end
