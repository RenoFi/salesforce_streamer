module SalesforceStreamer
  class Server
    attr_writer :push_topics
    attr_reader :client

    def initialize(push_topics: [])
      @push_topics = push_topics
    end

    def run
      Log.info "Starting server"
      catch_signals
      reset_client
      EM.run { subscribe }
    end

    def restart
      Log.info "Restarting server"
      reset_client
      EM.next_tick { subscribe }
    end

    private

    def catch_signals
      %w[INT USR1 USR2 TERM TTIN TSTP].each do |sig|
        trap sig do
          puts "Caught signal #{sig}. Shutting down..."
          exit 0
        end
      end
    end

    def reset_client
      @client = Restforce.new
      client.authenticate!
      Configuration.instance.faye_extensions.each do |extension|
        Log.debug %(adding Faye extension #{extension})
        extension.server = self if extension.respond_to?(:server=)
        client.faye.add_extension extension
      end
    end

    def subscribe
      @push_topics.each do |topic|
        client.subscribe topic.name, replay: Configuration.instance.replay_adapter do |message|
          Log.info "Message #{message.dig("event", "replayId")} received from topic #{topic.name}"
          topic.handle message
        end
      end
    end
  end
end
