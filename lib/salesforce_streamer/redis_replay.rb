# frozen_string_literal: true

module SalesforceStreamer
  class RedisReplay
    class << self
      def redis_connection
        @redis_connection ||= Configuration.instance.redis_connection || raise(RedisConnectionError)
      end

      attr_writer :redis_connection
    end

    def connection
      if RedisReplay.redis_connection.respond_to?(:with)
        RedisReplay.redis_connection.with do |conn|
          yield(conn)
        end
      else
        yield RedisReplay.redis_connection
      end
    end

    # Saves the value in a sorted set named by the key
    # The score is the ReplayId integer value
    def record(key, value)
      return unless key && value

      key = namespaced_key(key)
      value = Integer(value)
      # The score is the value
      connection { |c| c.zadd key, value, value }
    rescue StandardError, TypeError => e
      Configuration.instance.exception_adapter.call e
      nil
    end

    # Retrives the highest value in the sorted set
    def retrieve(key)
      return unless key

      key = namespaced_key(key)
      value = connection { |c| c.zrevrange(key, START, STOP)&.first }
      Integer(value) if value
    rescue StandardError => e
      Configuration.instance.exception_adapter.call e
      nil
    end

    private

    def namespaced_key(key)
      NAMESPACE + key.to_s
    end

    NAMESPACE = 'SalesforceStreamer:'
    START = 0
    STOP = 0
  end
end
