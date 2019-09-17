# frozen_string_literal: true

module SalesforceStreamer
  class Server
    attr_writer :push_topics

    def self.configure
      yield Configuration.instance
      Configuration.instance.server = self
    end

    def initialize(push_topics: [])
      @logger = Configuration.instance.logger
      @push_topics = push_topics
      @client = Restforce.new
    end

    def run
      @client.authenticate!
      @logger.info 'Starting Server'
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

    def start_em
      EM.run do
        @push_topics.map do |topic|
          @client.subscribe topic.name, replay: topic.replay.to_i do |msg|
            @logger.debug(msg)
            topic.handler_constant.call(msg)
            @logger.info("Message processed: channel=#{topic.name} replayId=#{msg.dig('event', 'replayId')}")
          end
        end
      end
    end
  end
end
