require 'bundler/setup'
require 'byebug'
require 'ostruct'
require 'salesforce_streamer'

Dir.glob('./spec/factories/**/*').each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    SalesforceStreamer::Configuration.instance = SalesforceStreamer::Configuration.new
  end
end

class TestHandlerClass
  def self.call(message); end
end
