module SalesforceStreamer
  ReplayIdError = Class.new(StandardError)

  class MissingCLIFlagError < StandardError
    def initialize(flag)
      super "Missing required command line flag: #{flag}"
    end
  end

  class NilQueryError < StandardError
    def initialize(name)
      super "Query not defined for #{name}"
    end
  end

  class PushTopicHandlerMissingError < StandardError
    def initialize(message)
      super "Unable to load constant #{message}."
    end
  end

  class PushTopicNameTooLongError < StandardError
    def initialize(name)
      super "PushTopic name: #{name} (#{name.size}/25)"
    end
  end

  class UnprocessableHandlerError < StandardError
    def initialize(constant)
      super "#{constant} does not repond to .call or .perform_async"
    end
  end
end
