# frozen_string_literal: true

require 'optparse'
require 'salesforce_streamer'
require 'salesforce_streamer/configuration'

module SalesforceStreamer
  class CLI
    def initialize(argv)
      @argv = argv
      @config = Configuration.new
      setup_options
      @parser.parse! @argv
    end

    def run
      # initialize new server with @config
      # start the server
    end

    private

    def setup_options
      @parser = OptionParser.new do |o|
        o.on "-C", "--config PATH", "Load PATH as a config file" do |arg|
          @config.load_services arg
        end

        o.on "-e", "--environment ENVIRONMENT",
          "The environment to run the app on (default development)" do |arg|
          @config.environment = arg
        end

        o.on "-v", "--verbose", "Activate the Restforce logger" do
          @config.logger = Logger.new(STDOUT)
          @config.restforce_logger!
        end

        o.on "-V", "--version", "Print the version information" do
          puts "streamer version #{SalesforceStreamer::VERSION}"
          exit 0
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
