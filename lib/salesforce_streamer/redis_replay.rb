module SalesforceStreamer
  class RedisReplay
    class << self
      def redis_connection
        @redis_connection ||= Configuration.instance.redis_connection || fail(RedisConnectionError)
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

    # Saves the value to a key with expiration
    def record(key, value)
      return unless key && value

      key = namespaced_key(key)
      value = Integer(value)
      connection { |c| c.setex key, SECONDS_TO_EXPIRE, value }
    rescue StandardError => e
      Configuration.instance.exception_adapter.call e
      nil
    end

    def retrieve(key)
      return unless key

      key = namespaced_key(key)
      value = connection { |c| c.get key }
      Integer(value) if value
    rescue StandardError => e
      Configuration.instance.exception_adapter.call e
      nil
    end

    private

    def namespaced_key(key)
      NAMESPACE + key.to_s
    end

    NAMESPACE = 'SalesforceStreamer:'.freeze
    SECONDS_TO_EXPIRE = 24 * 60 * 60 # 24 hours
    START = 0
    STOP = 0
  end
end
