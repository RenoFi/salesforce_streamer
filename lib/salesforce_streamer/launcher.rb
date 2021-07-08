module SalesforceStreamer
  # SalesforceStreamer::Launcher is the entry point for starting the Restforce
  # Streaming API server. It is responsible for upserting each PushTopic and
  # starting the server.
  class Launcher
    def initialize
      load_server_configuration
      @manager = SalesforceTopicManager.new push_topics: @push_topics
      @server = Server.new push_topics: @push_topics
    end

    # Manages each PushTopic configured and starts the Streaming API listener.
    def run
      Log.info 'Launching Streamer Services'
      @manager.upsert_topics!
      @server.push_topics = @manager.push_topics
      @server.run
    end

    private

    def load_server_configuration
      require_application
      initialize_push_topics
    end

    def require_application
      return unless Configuration.instance.require_path

      Log.debug 'Loading the require path'
      require Configuration.instance.require_path
    end

    def initialize_push_topics
      Log.debug 'Loading and validating PushTopics configuration'
      @push_topics = []
      Configuration.instance.push_topic_data.each_value do |topic_data|
        Log.debug topic_data.to_s
        @push_topics << PushTopic.new(**topic_data.transform_keys(&:to_sym))
      end
    end
  end
end
