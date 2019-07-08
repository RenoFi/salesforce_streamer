# frozen_string_literal: true

module SalesforceStreamer
  class Server
    attr_writer :push_topics

    def initialize(config:, push_topics: [])
      @logger = config.logger
      @push_topics = push_topics
      @client = ::SalesforceStreamer.salesforce_client
    end

    def run
      @client.authenticate!
      @logger.info 'Starting Server'
      EM.run do
        @push_topics.each do |topic|
          @client.subscribe(topic.name, replay: topic.replay) do |msg|
            @logger.debug(msg)
            topic.handler_constant.call(msg)
            @logger.info("Message processed: channel=#{msg['channel']} replayId=#{msg.dig('data', 'event', 'replayId')}")
          end
        end
      end
    end
  end
end
