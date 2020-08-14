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

  describe '#replay_adapter.call(topic)' do
    subject { config.replay_adapter.call(push_topic) }

    let(:config) { described_class.new }

    context 'given a PushTopic' do
      let(:push_topic) { PushTopicFactory.make }

      specify { expect(subject).to eq(-1) }
    end
  end

  describe '#middleware' do
    let(:config) { described_class.new }

    describe '#size' do
      specify { expect(config.middleware.size).to eq 0 }
    end

    context 'when #use_middleware' do
      let(:middleware) { Class.new }

      before do
        config.use_middleware middleware
      end

      describe '#size' do
        specify { expect(config.middleware.size).to eq 1 }
      end
    end
  end

  describe '#middleware_runner' do
    subject { config.middleware_runner(proc {}) }

    let(:config) { described_class.new }

    specify { expect(subject).to respond_to :call }

    context 'given some middleware' do
      let(:middleware_with_args) do
        Class.new do
          def initialize(app, arg1)
            @app = app
            @arg1 = arg1
          end

          def call(message)
            @app.call(message)
            @arg1
          end
        end
      end
      let(:simple_middleware) do
        Class.new do
          def initialize(app)
            @app = app
          end

          def call(message)
            @app.call(message)
          end
        end
      end

      before do
        config.use_middleware(simple_middleware)
        config.use_middleware(middleware_with_args, 'argument1')
      end

      specify { expect(subject).to respond_to :call }

      describe '#call' do
        specify do
          expect(simple_middleware)
            .to receive(:new)
            .with(Proc)
            .and_call_original
          expect(middleware_with_args)
            .to receive(:new)
            .with(Object, 'argument1')
            .and_call_original

          expect(subject.call('hello')).to eq 'argument1'
        end
      end
    end
  end
end
