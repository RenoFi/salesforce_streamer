# frozen_string_literal: true

module SalesforceStreamer
  class TopicManager
    attr_reader :push_topics

    def initialize(push_topics:, config:)
      @push_topics = push_topics
      @config = config
      @logger = config.logger
      @client = ::SalesforceStreamer.salesforce_client
    end

    def run
      return unless @config.manage_topics?
      @logger.info 'Running Topic Manager'
      @push_topics.each do |push_topic|
        @logger.debug push_topic.to_s
        if diff?(push_topic)
          @logger.debug 'diff?=true'
          upsert(push_topic)
        end
      end
    end

    private

    def diff?(push_topic)
      hashie = @client.push_topic_by_name(push_topic.name)
      return true unless hashie
      @logger.debug hashie.to_h.to_s
      push_topic.id = hashie.Id
      return true unless push_topic.query.eql?(hashie.Query)
      return true unless push_topic.name.eql?(hashie.Name)
      return true unless push_topic.notify_for_fields.eql?(hashie.NotifyForFields)
      return true unless push_topic.api_version.eql?(hashie.ApiVersion)
      false
    end

    def upsert(push_topic)
      @client.upsert_push_topic(push_topic)
    end
  end
end
