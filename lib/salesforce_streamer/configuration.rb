module SalesforceStreamer
  # Manages server configuration.
  class Configuration
    attr_accessor :environment, :logger, :require_path, :config_file, :manage_topics,
      :server, :exception_adapter, :redis_connection, :middleware, :replay_adapter

    class << self
      attr_writer :instance
    end

    def self.instance
      @instance ||= new
    end

    def initialize
      @environment = ENV['RACK_ENV'] || :development
      @logger = Logger.new(IO::NULL)
      @exception_adapter = proc { |exc| fail(exc) }
      @replay_adapter = proc { |topic| topic.id || topic.replay }
      @manage_topics = false
      @config_file = './config/streamer.yml'
      @require_path = './config/environment'
      @middleware = []
    end

    def manage_topics?
      @manage_topics
    end

    def use_middleware(klass, *args, &block)
      middleware << proc { |app| klass.new(app, *args, &block) }
    end

    def middleware_chain_for(app)
      middleware.reduce(app) { |memo, middleware| middleware.call(memo) }
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
