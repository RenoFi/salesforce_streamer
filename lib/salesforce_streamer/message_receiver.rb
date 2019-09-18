module SalesforceStreamer
  class MessageReceiver
    class << self
      # @param topic [String] The unique Salesforce Topic name
      # @param handler [Object] An object that responds to .call(message)
      # @param message [Hash] The event payload
      def call(topic, handler, message)
        handler.call message
      rescue StandardError => e
        Configuration.instance.exception_adapter.call e
      end
    end
  end
end
