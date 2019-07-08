# frozen_string_literal: true

require 'faye'
require 'salesforce_streamer/version'

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
# Turn on verbose logging for troubleshooting. This will also activate the
# Restforce logger, so this is not recommended for production.
#
#     bundle exec streamer -C config/streamer.yml -v
#
module SalesforceStreamer
end
