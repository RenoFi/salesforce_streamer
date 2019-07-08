# frozen_string_literal: true

require 'yaml'
require 'logger'

module SalesforceStreamer
  # Manages server configuration.
  class Configuration
    attr_accessor :environment, :logger
    attr_reader :services

    def initialize
      @logger = Logger.new(IO::NULL)
    end

    def load_services(path)
      @services = YAML.safe_load(File.read(path))
    end

    def restforce_logger!
      Restforce.log = true
    end
  end
end
