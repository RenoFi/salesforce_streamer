# frozen_string_litera: true

RSpec.describe SalesforceStreamer::Configuration do
  describe '.new' do
    subject { described_class.new }

    specify { expect(subject).to respond_to(:environment) }
    specify { expect(subject).to respond_to(:environment=) }
    specify { expect(subject).to respond_to(:config_file) }
    specify { expect(subject).to respond_to(:config_file=) }
    specify { expect(subject).to respond_to(:exception_adapter) }
    specify { expect(subject).to respond_to(:exception_adapter=) }
    specify { expect(subject).to respond_to(:persistence_adapter) }
    specify { expect(subject).to respond_to(:persistence_adapter=) }
    specify { expect(subject).to respond_to(:logger) }
    specify { expect(subject).to respond_to(:logger=) }
    specify { expect(subject).not_to respond_to(:push_topic_data=) }
  end

  describe '#push_topic_data' do
    subject { config.push_topic_data }

    let(:config) { described_class.new }

    context 'when YAML file has development key' do
      before { config.config_file = './spec/fixtures/configuration/config.yml' }

      specify { expect(subject).to be_a Hash }
    end
  end

  describe '#exception_adapter.call(exception)' do
    let(:config) { described_class.new }

    context 'given an Exception' do
      subject { config.exception_adapter.call exception }

      let(:exception) { StandardError.new('error') }

      specify { expect { subject }.to raise_exception { exception } }
    end
  end
end
