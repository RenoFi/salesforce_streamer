# Changelog

Sorted so that the most recent change logs are near the top. Only significant
changes are logged in the change log.

## 2024-02-29 Krzysztof Knapik

v2.10 Drop ruby 3.0 and add ruby 3.3 support

## 2023-07-26 Krzysztof Knapik

v2.9 take default api version from `SALESFORCE_API_VERSION` env var

## 2023-02-14 Krzysztof Knapik

v2.8 bump dependency constraints, restforce 6.2+

## 2022-08-01 Krzysztof Knapik

v2.7 bump dependency constraints

## 2022-04-10 Krzysztof Knapik

v2.6 drops ruby 2.7 support and adds ruby 3.1 support

## 2020-08-17 Scott Serok [scott@renofi.com](mailto:scott@renofi.com)

v2.1 changes the expected interface of `Configuration#replay_adapter`.

Normally this breaking change would require a major version bump, but since the
functionality today is quiet broken we can call this a major bug fix.

The `config.replay_adapter` should be an object that has an interface like Hash.
It must respond to `[]` and `[]=`. By default the adapter is an empty hash.  If
you want your push topic replayId to persist between restarts, then you should
implement a class with an appropriate interface.

```ruby
class MyReplayAdapter
  def [](channel)
    MyPersistence.get(channel)
  end

  def []=(channel, replay_id)
    MyPersistence.set(channel, replay_id)
  end
end
```

This change was sparked by a misunderstanding of the
`Restforce::Concerns::Streaming::ReplayExtension` replay handlers.
SalesforceStreamer can eliminate some complexity and fix a bug by delegating the
responsibility of maintaining the current replayId to that ReplayExtension. The
object will be used on each request/response cycle to record and read the latest
replayId as long as the object assigned to `config.replay_adapter` responds to
`[]` and `[]=`.

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
      (MyStore.fetch_replay_id(topic.name) || -1).to_i
    }

This will be used to set the replayId value when subscribing to the PushTopic.
