RSpec.describe SalesforceStreamer::MessageReceiver do
  describe '.call' do
    subject { described_class.call(topic, handler, message) }

    context 'topic: T' do
      let(:topic) { 'T' }

      context 'handler: TestHandlerClass' do
        let(:handler) { TestHandlerClass }

        context 'message: Hash' do
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

          it 'passes the message to TestHandlerClass.call' do
            expect(TestHandlerClass).to receive(:call).with(message)
            subject
          end
        end

        context 'message: []' do
          let(:message) { [] }
          it 'SalesforceStreamer::Configuration.instance.exception_adapter receives .call' do
            expect(SalesforceStreamer::Configuration.instance.exception_adapter).to receive(:call).with(instance_of(TypeError))
            subject
          end
        end
      end
    end
  end
end
