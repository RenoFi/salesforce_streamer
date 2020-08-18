[![Gem Version](https://badge.fury.io/rb/salesforce_streamer.svg)](https://rubygems.org/gems/salesforce_streamer)
[![Build Status](https://travis-ci.org/RenoFi/salesforce_streamer.svg?branch=master)](https://travis-ci.org/RenoFi/salesforce_streamer)

# salesforce_streamer

A wrapper around the Restforce Streaming API to receive real time updates from
your Salesforce instance with a built-in PushTopic manager.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'salesforce_streamer'
```

And then execute:

    $ bundle

## Usage

### Configure Push Topics

Create a YAML file to configure your PushTopic subscriptions. When streamer
starts up it will check for any differences between Salesforce PushTopics and
this yaml and update any differences when `config.manage_topics = true`.

```yaml
# config/streamer.yml
---
base: &DEFAULT
  accounts:
    handler: "AccountChangeHandler"
    replay: -1
    name: "AllAccounts"
    api_version: "49.0"
    description: "Sync Accounts"
    notify_for_fields: "Referenced"
    query: "Select Id, Name From Account"

development:
  <<: *DEFAULT

test:
  <<: *DEFAULT

production:
  <<: *DEFAULT
```

### Define Message Handlers

Define your handlers somewhere in your project. They must respond to either
`.perform_async(str)` or `.call(str)`.

```ruby
# lib/account_change_handler.rb
# Handle account changes inline
class AccountChangeHandler
  class << self
    def call(message)
      puts message
    end
  end
end

# Handle account changes asynchronously
class AccountChangeHandler
  include Sidekiq::Worker

  def perform(message)
    puts message
  end
end
```

### Prepare The Environment

Set your Restforce ENV variables in order to establish a connection. See the
Restforce API documentation for more details. Then start the server using the
command line interface.

Configure the `SalesforceStreamer` module.

```ruby
# config/initializers/salesforce_streamer.rb

SalesforceStreamer.configure do |config|
  config.logger = Logger.new(STDERR, level: 'INFO')
  config.exception_adapter = proc { |e| puts e }
  config.replay_adapter = MyReplayAdapter
  config.use_middleware AfterMessageReceived
  config.manage_topics = true
end
```

### Launch The Streamer

Launch the `streamer` service loads the application code at
`./config/environment` by default if `config.require_path` is unset. It will
load your push topic configuration from `./config/streamer.yml` if
`config.config_file` is unset. During the boot sequence it will connect to
Salesforce using the Restforce client and your configured ENV variables in order
to upsert push topic definitions.

```
$ bundle exec streamer
I, [2019-07-08T22:16:34.104271 #26973]  INFO -- : Launching Streamer Services
I, [2019-07-09T15:19:55.862351 #78537]  INFO -- : Running Topic Manager
I, [2019-07-09T15:19:56.860998 #78537]  INFO -- : New PushTopic AllAccounts
I, [2019-07-09T15:19:56.861079 #78537]  INFO -- : Upsert PushTopic AllAccounts
I, [2019-07-09T15:19:56.861109 #78537]  INFO -- : Skipping upsert because manage topics is off
I, [2019-07-08T22:16:34.794933 #26973]  INFO -- : Starting Server
```

By default, the server will start up without syncing the push topic configuration.
Set the configuration option `config.manage_topics = true` will tell the server
launcher to update the configuration of the push topic in Salesforce.

```
$ bundle exec streamer
I, [2019-07-09T15:19:55.862296 #78537]  INFO -- : Launching Streamer Services
I, [2019-07-09T15:19:55.862351 #78537]  INFO -- : Running Topic Manager
I, [2019-07-09T15:19:56.860998 #78537]  INFO -- : New PushTopic AllAccounts
I, [2019-07-09T15:19:56.861079 #78537]  INFO -- : Upsert PushTopic AllAccounts
I, [2019-07-09T15:19:57.591241 #78537]  INFO -- : Starting Server
```

By default, the executable will load the YAML based on the `RACK_ENV` environment
variable, or default to `:development` if not set. You can override this by
setting the `config.environment = :integration`

### Message Handling Middleware

You can initialize the streamer server with any number of middleware classes.
When a message is received by a PushTopic subscription, the chain of middleware
classes are executed before the message handler is called.

```ruby
# config/initializers/streamer.rb
class MySimpleMiddleware
  def initialize(handler)
    @handler = handler
  end

  def call(message)
    @handler.call(message)
  end
end

SalesforceStreamer.config.use_middleware MySimpleMiddleware
```

### ReplayAdapter

The `config.replay_adapter` should be an object that has an interface like Hash.
It must respond to `[]` and `[]=`. By default the adapter is an empty hash.  If
you want your push topic replayId to persist between restarts, then you should
implement a class with an appropriate interface.

```ruby
class MyReplayAdapter
  def [](channel)
    Persistence.get(channel)
  end

  def []=(channel, replay_id)
    Persistence.set(channel, replay_id)
  end
end
```

This adapter will be used directly by `Restforce::ReplayExtension`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/renofi/salesforce_streamer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
