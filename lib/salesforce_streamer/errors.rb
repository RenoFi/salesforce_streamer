module SalesforceStreamer
  ReplayIdError = Class.new(StandardError)

  class MissingCLIFlagError < StandardError
    def initialize(flag)
      super 'Missing required command line flag: ' + flag.to_s
    end
  end

  class NilQueryError < StandardError
    def initialize(name)
      super 'Query not defined for ' + name.to_s
    end
  end

  class PushTopicHandlerMissingError < StandardError
    def initialize(message)
      super "Unable to load constant #{message}."
    end
  end

  class PushTopicNameTooLongError < StandardError
    def initialize(name)
      super 'PushTopic name: ' + name.to_s + ' (' + name.size.to_s + '/25)'
    end
  end
end
