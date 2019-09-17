# frozen_string_literal: true

module SalesforceStreamer
  class SalesforceClient
    def initialize(client: Restforce.new)
      @client = client
    end

    def authenticate!
      @client.authenticate!
    end

    def subscribe(*args)
      @client.subscribe(args) do
        yield
      end
    end

    # Returns nil or an instance of Restforce::SObject
    def find_push_topic_by_name(name)
      query = QUERY.dup.gsub(/\s+/, ' ').gsub('{{NAME}}', name)
      @client.query(query).first
    end

    # Returns true or raises an exception if the upsert fails
    def upsert_push_topic(push_topic)
      @client.upsert!('PushTopic', :Id,
                      'Id' => push_topic.id,
                      'Name' => push_topic.name,
                      'ApiVersion' => push_topic.api_version,
                      'Description' => push_topic.description,
                      'NotifyForFields' => push_topic.notify_for_fields,
                      'Query' => push_topic.query)
    end

    private

    QUERY = <<~SOQL.chomp.freeze
      SELECT Id, Name, ApiVersion, Description, NotifyForFields, Query, isActive
      FROM PushTopic
      WHERE Name = '{{NAME}}'
    SOQL
  end
end
