# frozen_string_literal: true

module SalesforceStreamer
  class CLI
    def initialize(argv)
      @argv = argv
      @config = Configuration.new
      setup_options
      @parser.parse! @argv
    end

    def run
      Launcher.new(config: @config).run
    end

    private

    def setup_options
      @parser = OptionParser.new do |o|
        o.on "-C", "--config PATH", "Load PATH as a config file" do |arg|
          @config.load_push_topic_data arg
        end

        o.on "-e", "--environment ENVIRONMENT",
          "The environment to run the app on (default development)" do |arg|
          @config.environment = arg
        end

        o.on "-r", "--restforce-logger", "Activate the Restforce logger" do
          @config.restforce_logger!
        end

        o.on "-v", "--verbose LEVEL", "Set the log level (default no logging)" do |arg|
          logger = Logger.new(STDOUT)
          logger.level = arg
          @config.logger = logger
        end

        o.on "-V", "--version", "Print the version information" do
          puts "streamer version #{SalesforceStreamer::VERSION}"
          exit 0
        end

        o.on "-x", "--topics", "Activate PushTopic Management (default off)" do
          @config.manage_topics = true
        end

        o.banner = "streamer OPTIONS"

        o.on_tail "-h", "--help", "Show help" do
          puts o
          exit 0
        end
      end
    end
  end
end
