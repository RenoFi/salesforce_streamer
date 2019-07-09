# frozen_string_literal: true

module SalesforceStreamer
  # Manages server configuration.
  class Configuration
    attr_accessor :environment, :logger
    attr_reader :push_topic_data
    attr_writer :manage_topics

    def initialize
      @environment = ENV['RACK_ENV'] || :development
      @logger = Logger.new(IO::NULL)
      @manage_topics = false
    end

    def manage_topics?
      @manage_topics
    end

    def load_push_topic_data(path)
      data = YAML.safe_load(File.read(path), [], [], true)
      @push_topic_data = data[environment.to_s]
    end

    def restforce_logger!
      Restforce.log = true
    end
  end
end
