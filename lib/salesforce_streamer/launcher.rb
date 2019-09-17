# frozen_string_literal: true

module SalesforceStreamer
  # SalesforceStreamer::Launcher is the entry point for starting the Restforce
  # Streaming API server. It is responsible for upserting each PushTopic and
  # starting the server.
  class Launcher
    def initialize
      @logger = Configuration.instance.logger
      load_server_configuration
      @manager = TopicManager.new push_topics: @push_topics
      @server = Server.new push_topics: @push_topics
    end

    # Manages each PushTopic configured and starts the Streaming API listener.
    def run
      @logger.info 'Launching Streamer Services'
      @manager.run
      @server.push_topics = @manager.push_topics
      @server.run
    end

    private

    def load_server_configuration
      require_application
      initialize_push_topics
    end

    def require_application
      if Configuration.instance.require_path
        @logger.debug 'Loading the require path'
        require Configuration.instance.require_path
      end
    end

    def initialize_push_topics
      @logger.debug 'Loading and validating PushTopics configuration'
      @push_topics = []
      Configuration.instance.push_topic_data.values.each do |topic_data|
        @logger.debug topic_data.to_s
        @push_topics << PushTopic.new(data: topic_data)
      end
    end
  end
end
