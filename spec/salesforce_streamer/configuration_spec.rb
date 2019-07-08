# frozen_string_litera: true

RSpec.describe SalesforceStreamer::Configuration do
  describe '.new' do
    subject { described_class.new }

    specify { expect(subject).to respond_to(:environment) }
    specify { expect(subject).to respond_to(:environment=) }
    specify { expect(subject).to respond_to(:logger) }
    specify { expect(subject).to respond_to(:logger=) }
    specify { expect(subject).to respond_to(:push_topic_data) }
    specify { expect(subject).not_to respond_to(:push_topic_data=) }
  end

  describe '#load_push_topic_data' do
    let(:config) { described_class.new }
    subject { config.load_push_topic_data path }

    context 'when YAML file has development key' do
      let(:path) { './spec/fixtures/configuration/config.yml' }

      specify { expect(subject).to be_a Hash }
    end
  end
end
