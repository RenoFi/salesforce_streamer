# frozen_string_literal: true

module SalesforceStreamer
  # Manages server configuration.
  class Configuration
    attr_accessor :environment, :logger, :require_path, :config_file
    attr_writer :manage_topics

    def self.instance
      @instance ||= new
    end

    def initialize
      @environment = ENV['RACK_ENV'] || :development
      @logger = Logger.new(IO::NULL)
      @manage_topics = false
      @config_file = './config/streamer.yml'
      @require_path = './config/application'
    end

    def manage_topics?
      @manage_topics
    end

    def push_topic_data
      return @push_topic_data if @push_topic_data
      data = YAML.safe_load(File.read(config_file), [], [], true)
      @push_topic_data = data[environment.to_s]
    end

    def restforce_logger!
      Restforce.log = true
    end
  end
end
