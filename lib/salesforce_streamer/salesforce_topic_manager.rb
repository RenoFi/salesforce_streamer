module SalesforceStreamer
  class SalesforceTopicManager
    attr_reader :push_topics

    def initialize(push_topics:)
      @push_topics = push_topics
      @client = SalesforceClient.new
    end

    def upsert_topics!
      Log.info 'Starting to upsert PushTopic definitions into Salesforce'
      @push_topics.each do |push_topic|
        Log.info push_topic.name
        Log.debug push_topic.attributes.to_json
        upsert(push_topic) if diff?(push_topic)
      end
    end

    private

    def diff?(push_topic)
      hashie = @client.find_push_topic_by_name(push_topic.name)
      unless hashie
        Log.info "New PushTopic #{push_topic.name}"
        return true
      end
      Log.debug "Remote PushTopic found with hash=#{hashie.to_h}"
      push_topic.id = hashie.Id
      return true unless push_topic.query.eql?(hashie.Query)
      return true unless push_topic.notify_for_fields.eql?(hashie.NotifyForFields)
      return true unless push_topic.api_version.to_s.eql?(hashie.ApiVersion.to_s)

      Log.info 'No differences detected'
      false
    end

    def upsert(push_topic)
      Log.info "Upserting PushTopic"
      if Configuration.instance.manage_topics?
        @client.upsert_push_topic(push_topic)
      else
        Log.info 'Skipping upsert because manage topics is off'
      end
    end
  end
end
