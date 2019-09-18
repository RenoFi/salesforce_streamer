# frozen_string_literal: true

module SalesforceStreamer
  class RedisReplay
    class << self
      def redis_connection
        @redis_connection ||= Configuration.instance.redis_connection
      end

      attr_writer :redis_connection
    end

    # Saves the value in a sorted set named by the key
    # The score is the ReplayId integer value
    def record(key, value)
      return unless value

      value = Integer(value)
      # The score is the value
      RedisReplay.redis_connection.zadd key, value, value
    rescue StandardError, TypeError => e
      Configuration.instance.exception_adapter.call e
      nil
    end

    # Retrives the highest value in the sorted set
    def retrieve(key)
      value = RedisReplay.redis_connection.zrevrange(key, START, STOP)&.first
      Integer(value) if value
    rescue StandardError => e
      Configuration.instance.exception_adapter.call e
      nil
    end

    START = 0
    STOP = 0
  end
end
