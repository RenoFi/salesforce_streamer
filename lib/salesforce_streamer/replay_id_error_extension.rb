module SalesforceStreamer
  class ReplayIdErrorExtension
    REPLAY_ERROR_REGEX = /^400::The replayId /

    def incoming(message, callback)
      if message["error"]&.match?(REPLAY_ERROR_REGEX)
        fail ReplayIdError, message["error"]
      end

      callback.call message
    end
  end
end
