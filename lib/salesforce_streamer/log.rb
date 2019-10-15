module SalesforceStreamer
  class Log
    class << self
      extend Forwardable

      def_delegators :instance, :debug, :info, :warn, :error, :critical

      def instance
        @instance ||= Configuration.instance.logger
      end
    end
  end
end
