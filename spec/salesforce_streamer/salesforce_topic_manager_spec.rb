RSpec.describe SalesforceStreamer::SalesforceTopicManager do
  let(:client) do
    instance_double(SalesforceStreamer::SalesforceClient,
      find_push_topic_by_name: {},
      upsert_push_topic: true)
  end
  let(:config) { SalesforceStreamer::Configuration.instance }

  before do
    SalesforceStreamer::Configuration.instance.require_path = nil
    allow(SalesforceStreamer::SalesforceClient).to receive(:new) { client }
  end

  describe '.new' do
    subject { described_class.new push_topics: push_topics }

    context 'when push_topics is []' do
      let(:push_topics) { [] }

      specify { expect(subject).to respond_to :upsert_topics! }
    end
  end

  describe '#upsert_topics!' do
    subject { manager.upsert_topics! }

    let(:manager) { described_class.new push_topics: push_topics }

    context 'when [push_topic]' do
      let(:push_topic) { PushTopicFactory.make }
      let(:push_topics) { [push_topic] }

      it 'sets push_topic.id' do
        response = OpenStruct.new(Id: 'abc123')
        allow(client).to receive(:find_push_topic_by_name) { response }
        subject
        expect(push_topics[0].id).to eq 'abc123'
      end

      it 'does not upsert when find_push_topic_by_name returns nil' do
        allow(client).to receive(:find_push_topic_by_name) { nil }
        expect(client).not_to receive(:upsert_push_topic)
        subject
      end

      context 'when config.manage_topics = true' do
        before { config.manage_topics = true }

        it 'sets push_topic.id' do
          response = OpenStruct.new(Id: 'abc123')
          allow(client).to receive(:find_push_topic_by_name) { response }
          subject
          expect(push_topics[0].id).to eq response.Id
        end

        it 'does not call upsert when no changes' do
          h = {
            Id: 'a1',
            Name: push_topics[0].name,
            NotifyForFields: push_topics[0].notify_for_fields,
            Query: push_topics[0].query,
            ApiVersion: push_topics[0].api_version
          }
          response = OpenStruct.new(h)
          allow(client).to receive(:find_push_topic_by_name) { response }
          expect(client).not_to receive(:upsert_push_topic)
          subject
        end

        it 'upsert when find_push_topic_by_name returns nil' do
          allow(client).to receive(:find_push_topic_by_name) { nil }
          expect(client).to receive(:upsert_push_topic)
          subject
        end

        it 'upsert when push topic query changes' do
          h = {
            Id: 'a1',
            Name: push_topics[0].name,
            NotifyForFields: push_topics[0].notify_for_fields,
            Query: 'Select Id, Name From Account',
            ApiVersion: push_topics[0].api_version
          }
          response = OpenStruct.new(h)
          allow(client).to receive(:find_push_topic_by_name) { response }
          expect(client).to receive(:upsert_push_topic)
          subject
        end

        it 'upsert when push topic notify_for_fields changes' do
          h = {
            Id: 'a1',
            Name: push_topics[0].name,
            NotifyForFields: 'Select',
            Query: push_topics[0].query,
            ApiVersion: push_topics[0].api_version
          }
          response = OpenStruct.new(h)
          allow(client).to receive(:find_push_topic_by_name) { response }
          expect(client).to receive(:upsert_push_topic)
          subject
        end

        it 'upsert when push topic api_version changes' do
          h = {
            Id: 'a1',
            Name: push_topics[0].name,
            NotifyForFields: push_topics[0].notify_for_fields,
            Query: push_topics[0].query,
            ApiVersion: '1.0'
          }
          response = OpenStruct.new(h)
          allow(client).to receive(:find_push_topic_by_name) { response }
          expect(client).to receive(:upsert_push_topic)
          subject
        end
      end
    end
  end
end
