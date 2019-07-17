# frozen_string_literal: string

RSpec.describe SalesforceStreamer::TopicManager do
  let(:client) { double(find_push_topic_by_name: {}, upsert_push_topic: true) }
  let(:config) { SalesforceStreamer::Configuration.new }

  before { allow(SalesforceStreamer::SalesforceClient).to receive(:new) { client } }

  describe '.new' do
    subject { described_class.new push_topics: push_topics, config: config }

    context 'when push_topics is []' do
      let(:push_topics) { [] }

      specify { expect(subject).to respond_to :run }
    end
  end

  describe '#run' do
    let(:manager) { described_class.new push_topics: push_topics, config: config }

    subject { manager.run }

    context 'when [push_topic]' do
      let(:data) do
        {
          'handler' => 'TestHandlerClass',
          'salesforce' => {
            'name' => 'Name',
            'query' => 'Select Id From Account'
          }
        }
      end
      let(:push_topics) { [SalesforceStreamer::PushTopic.new(data: data)] }

      it 'sets push_topic.id' do
        response = OpenStruct.new(Id: 'abc123')
        allow(client).to receive(:find_push_topic_by_name) { response }
        subject
        expect(push_topics[0].id).to eq 'abc123'
      end

      it 'does not upsert when find_push_topic_by_name returns nil' do
        allow(client).to receive(:find_push_topic_by_name) { nil }
        expect(client).to_not receive(:upsert_push_topic)
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
          expect(client).to_not receive(:upsert_push_topic)
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
