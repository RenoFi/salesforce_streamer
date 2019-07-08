# frozen_string_literal: true

require 'faye'
require 'logger'
require 'optparse'
require 'restforce'
require 'yaml'

require 'salesforce_streamer/configuration'
require 'salesforce_streamer/errors'
require 'salesforce_streamer/push_topic'
require 'salesforce_streamer/topic_manager'
require 'salesforce_streamer/salesforce_client'
require 'salesforce_streamer/server'
require 'salesforce_streamer/version'
require 'salesforce_streamer/launcher'


# SalesforceStreamer wraps the Restforce Streaming API implementation so that
# your PushTopics are managed in the same place as your server set up.
#
# Establishing a connection to your Salesforce instances is performed using the
# Restforce client and your ENV variables.
#
#     export SALESFORCE_HOST="test.salesforce.com"
#     export SALESFORCE_USERNAME="user@domain.tld"
#     export SALESFORCE_PASSWORD="password"
#     export SALESFORCE_SECURITY_TOKEN="security token"
#     export SALESFORCE_CLIENT_ID="long client id"
#     export SALESFORCE_CLIENT_SECRET="long client secret"
#     export SALESFORCE_API_VERSION="41.0"
#
# Define each PushTopic and handler inside of a YAML config file and load it
# upon starting up the server.
#
#     bundle exec streamer -C config/streamer.yml
#
# Starting up the server takes a few moments before accepting new events. First,
# the server launches the PushTopic manager to upsert each PushTopic defined in
# the configuration file provided.  Once each PushTopic is up to date, then the
# server launches the event manager to listen for and handle messages.
#
# Turn on verbose logging for troubleshooting. The -r flag will activate the
# Restforce logger, so this is not recommended for production. The -v flag
# activates a Logger to STDOUT with DEBUG level by default. Set the log level
# with the -v flag.
#
#     bundle exec streamer -C config/streamer.yml -r
#     bundle exec streamer -C config/streamer.yml -v
#     bundle exec streamer -C config/streamer.yml -v INFO
#     bundle exec streamer -C config/streamer.yml -r -v
#     bundle exec streamer -C config/streamer.yml -r -v INFO
#
module SalesforceStreamer
  def self.salesforce_client
    @salesforce_client ||= SalesforceClient.new
  end
end
