module SalesforceStreamer
  class Server
    attr_writer :push_topics

    def initialize(push_topics: [])
      @push_topics = push_topics
    end

    def run
      Log.info 'Starting Server'
      catch_signals
      start_em
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

    def client
      return @client if @client
      @client = Restforce.new
      @client.authenticate!
      @client.faye.add_extension ReplayIdErrorExtension.new
      @client
    end

    def start_em
      EM.run do
        @push_topics.map do |topic|
          client.subscribe topic.name, replay: topic.replay.to_i do |message|
            replay_id = message.dig('event', 'replayId')
            Log.info "Message #{replay_id} received from topic #{topic.name}"
            topic.handle message
            topic.id = replay_id
          end
        end
      end
    end
  end
end
