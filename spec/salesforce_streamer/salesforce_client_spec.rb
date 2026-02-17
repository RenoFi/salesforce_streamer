RSpec.describe SalesforceStreamer::SalesforceClient do
  let(:client) { described_class.new(client: restforce) }
  let(:restforce) do
    instance_double(Restforce::Data::Client,
      authenticate!: true,
      subscribe: true,
      query: [],
      upsert!: true)
  end

  before do
    allow(restforce).to receive(:subscribe).and_yield
  end

  describe "#authenticate!" do
    subject { client.authenticate! }

    specify { expect(subject).to be(true) }
  end

  describe "#subscribe" do
    subject { client.subscribe handler_name, options, &block }

    context "given handler name and replay option" do
      let(:handler_name) { "TestHandlerClass" }
      let(:options) { {replay: -1} }
      let(:block) { proc { "yield content" } }

      specify { expect(subject).to eq "yield content" }
    end
  end

  describe "#find_push_topic_by_name" do
    subject { client.find_push_topic_by_name name }

    before { allow(restforce).to receive(:query) { response } }

    context "when name matches a PushTopic" do
      let(:name) { "Matching" }
      let(:records) { {"records" => [{"attributes" => {a: 1}}]} }
      let!(:response) { Restforce::Collection.new(records, nil) }

      specify { expect(subject).to be_a Restforce::SObject }

      it 'generates a proper SOQL query with "Matching"' do
        query = "SELECT Id, Name, ApiVersion, Description, NotifyForFields, Query, isActive FROM PushTopic WHERE Name = 'Matching'"
        expect(restforce).to receive(:query).with(query)
        subject
      end
    end

    context "when name does not match a PushTopic" do
      let(:name) { "NotMatching" }
      let(:records) { {"records" => []} }
      let!(:response) { Restforce::Collection.new(records, nil) }

      specify { expect(subject).to be_nil }
    end
  end

  describe "#upsert_push_topic" do
    subject { client.upsert_push_topic push_topic }

    context "given a push topic" do
      let(:push_topic) { PushTopicFactory.make description: "Something about it" }

      it "calls Restforce.upsert with proper arguments" do
        push_topic.id = 123
        attribute_hash = {
          "Id" => 123,
          "Name" => push_topic.name,
          "ApiVersion" => push_topic.api_version,
          "Description" => "Something about it",
          "NotifyForFields" => "Referenced",
          "Query" => push_topic.query
        }
        args = ["PushTopic", :Id, attribute_hash]
        expect(restforce).to receive(:upsert!).with(*args)
        subject
      end
    end
  end
end
