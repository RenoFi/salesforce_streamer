module SalesforceStreamer
  # Manages server configuration.
  class Configuration
    attr_accessor :environment, :require_path, :config_file, :manage_topics, :server, :exception_adapter, :persistence_adapter, :redis_connection
    attr_reader :logger

    class << self
      attr_writer :instance
    end

    def self.instance
      @instance ||= new
    end

    def initialize
      @environment = ENV['RACK_ENV'] || :development
      @exception_adapter = proc { |exc| fail(exc) }
      @persistence_adapter = RedisReplay.new
      @manage_topics = false
      @config_file = './config/streamer.yml'
      @require_path = './config/application'
      self.logger = Logger.new(IO::NULL)
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

    def logger=(object)
      @logger = Faye.logger = object
    end
  end
end
