module SalesforceStreamer
  # Manages server configuration.
  class Configuration
    attr_accessor :environment, :logger, :require_path, :config_file,
      :manage_topics, :exception_adapter, :replay_adapter
    attr_reader :middleware, :faye_extensions

    class << self
      attr_writer :instance

      def configure
        yield instance
      end

      def instance
        @instance ||= new
      end
    end

    def initialize
      @environment = ENV['RACK_ENV'] || :development
      @logger = Logger.new(IO::NULL)
      @exception_adapter = proc { |exc| fail(exc) }
      @replay_adapter = Hash.new { |hash, key| hash[key] = -1 }
      @manage_topics = false
      @config_file = './config/streamer.yml'
      @require_path = './config/environment'
      @middleware = []
      @faye_extensions = [ReplayIdErrorExtension.new]
    end

    def manage_topics?
      @manage_topics
    end

    # adds a setup proc to the middleware array
    def use_middleware(klass, *args, &block)
      @middleware << [klass, args, block]
    end

    # adds a Faye extension
    def use_faye_extension(extension)
      @faye_extensions << extension
    end

    # returns a ready to use chain of middleware
    def middleware_runner(last_handler)
      @middleware.reduce(last_handler) do |next_handler, current_handler|
        klass, args, block = current_handler
        klass.new(next_handler, *args, &block)
      end
    end

    def push_topic_data
      return @push_topic_data if @push_topic_data

      data = YAML.safe_load_file(config_file, aliases: true)
      @push_topic_data = data[environment.to_s] || data
    end

    def restforce_logger!
      Restforce.log = true
    end
  end
end
