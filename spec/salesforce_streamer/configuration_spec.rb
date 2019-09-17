# frozen_string_literal: true

# frozen_string_litera: true

RSpec.describe SalesforceStreamer::Configuration do
  describe '.new' do
    subject { described_class.new }

    specify { expect(subject).to respond_to(:environment) }
    specify { expect(subject).to respond_to(:environment=) }
    specify { expect(subject).to respond_to(:config_file) }
    specify { expect(subject).to respond_to(:config_file=) }
    specify { expect(subject).to respond_to(:logger) }
    specify { expect(subject).to respond_to(:logger=) }
    specify { expect(subject).not_to respond_to(:push_topic_data=) }
  end

  describe '#push_topic_data' do
    let(:config) { described_class.new }

    subject { config.push_topic_data }

    context 'when YAML file has development key' do
      before { config.config_file = './spec/fixtures/configuration/config.yml' }

      specify { expect(subject).to be_a Hash }
    end
  end
end
