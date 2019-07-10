[![Build Status](https://travis-ci.org/RenoFi/salesforce_streamer.svg?branch=master)](https://travis-ci.org/RenoFi/salesforce_streamer)

# SalesforceStreamer

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

Create a YAML file to configure your server subscriptions.  The configuration
for each subscription must have a nested `salesforce:` key. These settings will
be synced to your Salesforce instance when the `-x` flag is set on the command
line. For more information about the `replay:` and `notify_fields_for` options
please see the Salesforce Streaming API reference documentation.

```yaml
# config/streamer.yml
---
base: &DEFAULT
  accounts:
    handler: "AccountChangeHandler"
    replay: -1
    salesforce:
      name: "AllAccounts"
      api_version: "41.0"
      description: "Sync Accounts"
      notify_fields_for: "Referenced"
      query: "Select Id, Name From Account"

development:
  <<: *DEFAULT
```

It's important to note that the way push topics are managed is by the Salesforce
name attribute.  This should uniquely identify each push topic.  It is not
recommended to change the name of your push topic definitions; otherwise, the
push topic manager will not find a push topic in Salesforce resulting in the
creation of a brand new push topic. If the push topic manager identifies a
difference in any of the other Salesforce attributes, then it will update the
push topic in Salesforce before starting the streaming server.

### Define Message Handlers

Define your handlers somewhere in your project. They must respond to
`.call(str)`.

```ruby
# lib/account_change_handler.rb
class AccountChangeHandler
  def self.call(message)
    puts message
  end
end
```

### Prepare The Environment

Set your Restforce ENV variables in order to establish a connection. See the
Restforce API documentation for more details. Then start the server using the
command line interface.

### Launch The Streamer

Launch the `streamer` service, pointing it to your push topic configuration YAML
file and the entry point to your application.

```
$ bundle exec streamer -C config/streamer.yml -r ./lib/app -x -v INFO
I, [2019-07-09T15:19:55.862296 #78537]  INFO -- : Launching Streamer Services
I, [2019-07-09T15:19:55.862351 #78537]  INFO -- : Running Topic Manager
I, [2019-07-09T15:19:56.860998 #78537]  INFO -- : New PushTopic AllAccounts
I, [2019-07-09T15:19:56.861079 #78537]  INFO -- : Upsert PushTopic AllAccounts
I, [2019-07-09T15:19:57.591241 #78537]  INFO -- : Starting Server
```

For very verbose logs, also use the `--verbose-restforce` flag to activate the
Restforce client logger - not recommended for production.

You can start up the server without syncing the push topic configuration if you
know the topics are already configured appropriately. Remove the `-x` flag from
the CLI to skip the topic management component.

```
$ bundle exec streamer -C config/streamer.yml -r ./lib/app -v INFO
I, [2019-07-08T22:16:34.104271 #26973]  INFO -- : Launching Streamer Services
I, [2019-07-09T15:19:55.862351 #78537]  INFO -- : Running Topic Manager
I, [2019-07-09T15:19:56.860998 #78537]  INFO -- : New PushTopic AllAccounts
I, [2019-07-09T15:19:56.861079 #78537]  INFO -- : Upsert PushTopic AllAccounts
I, [2019-07-09T15:19:56.861109 #78537]  INFO -- : Skipping upsert because manage topics is off
I, [2019-07-08T22:16:34.794933 #26973]  INFO -- : Starting Server
```

By default, the CLI will load the YAML based on the `RACK_ENV` environment
variable, or default to `:development` if not set. You can override this in the
CLI with the `-e ENV` flag.

```
$ bundle exec streamer -C config/streamer.yml -r ./lib/app -e production
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/renofi/salesforce_streamer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SalesforceStreamer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/renofi/salesforce_streamer/blob/master/CODE_OF_CONDUCT.md).
