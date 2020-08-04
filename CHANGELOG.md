# Changelog

Sorted so that the most recent change logs are near the top. Only significant
changes are logged in the change log.

## 2020-08-04 Scott Serok [scott@renofi.com](mailto:scott@renofi.com)

v2.0 is released as a major simplification of this library. There are 2
significant differences from a user's perspective.

1. The YAML configuration requires minor edits to be compatible in v2.0.
2. The built-in Redis persistance of the replayId field has been removed. You
   should add a custom middleware and configure the new replay_adapter option.

### PushTopic configuration changes

After upgrading to v2, the YAML configuration should be modified. Shift the
nested "salesforce" block to the left and remove the "salesforce" key.

Before v2:

    name: "TopicName"
    handler: "MyConstant"
    salesforce:
      query: "SELECT Id FROM Lead"

As of v2:

    name: "TopicName"
    handler: "MyConstant"
    query: "SELECT Id FROM Lead"

### Redis Persistance removed

The original intention of this library is to manage PushTopic definitions
and run an event machine that subscribes to the Salesforce Streaming API based
on those PushTopics.

The addition of managing the Replay ID adds unecessary complexity that can be
incorporated through customization, and so it's been removed. You might use a
recent commit of v1 of this library for reference how to implement Redis as the
persistence layer.

To record the replayId on every message we can add a piece of middleware

    class RecordReplayIdMiddleware
      def initialize(handler)
        @handler = handler
      end

      def call(message)
        @handler.call(message)
        replay_id = message['event']['replayId']
        topic_name = message['topic']
        MyStore.record_replay_id(replay_id, topic_name)
      end
    end
    SalesforceStreamer.config.use_middleware RecordReplayIdMiddleware

To retrieve the replayId before subscribing to a PushTopic,
configure an adapter that returns an integer.

    SalesforceStreamer.config.replay_adapter = proc { |topic|
      MyStore.fetch_replay_id(topic.name) || -1
    }

This will be used to set the replayId value when subscribing to the PushTopic.
