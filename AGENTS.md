# AGENTS.md

## Cursor Cloud specific instructions

This is a Ruby gem project (`salesforce_streamer`) — a wrapper around the Restforce Streaming API. There is no web server or long-running service to start for development; all testing is done via RSpec.

### Ruby version

The project requires Ruby 4.0.1 (see `.ruby-version`). It is installed at `~/.rubies/ruby-4.0.1/bin` and added to `PATH` via `~/.bashrc`.

### Key commands

| Task | Command |
|---|---|
| Install deps | `bundle install` |
| Run tests | `bundle exec rake spec` |
| Run linter | `bundle exec rake standard` |
| Auto-fix lint | `bundle exec rake standard:fix` |
| Full CI suite | `bundle exec rake ci` (spec + standard) |
| Default rake | `bundle exec rake` (spec + standard:fix) |
| Build gem | `bundle exec rake build` |
| Interactive console | `bin/console` |

### Gotchas

- The `eventmachine` gem requires native compilation. Build dependencies (`build-essential`, `libssl-dev`) must be installed before `bundle install`.
- The test suite is fully mocked — no Salesforce credentials or external services are needed to run specs.
- The `bundle exec streamer` CLI requires Salesforce ENV vars and a YAML config; it is not runnable without a real Salesforce connection.
- Bundler version 4.0.4 matches the `Gemfile.lock` (`BUNDLED WITH`). The `.bundler-version` file says 4.0.7 but the lockfile pins 4.0.4.
