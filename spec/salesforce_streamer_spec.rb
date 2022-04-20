RSpec.describe SalesforceStreamer do
  it 'has a version number' do
    expect(SalesforceStreamer::VERSION).not_to be_nil
  end

  describe '.config' do
    subject { described_class.config }

    specify { expect(subject).to eq described_class::Configuration.instance }
  end

  describe '.configure' do
    specify do
      expect { |block| described_class.configure(&block) }
        .to yield_with_args(described_class::Configuration.instance)
    end
  end
end
