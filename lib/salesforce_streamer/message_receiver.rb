# frozen_string_literal: true

module SalesforceStreamer
  class MessageReceiver
    class << self
      # @param topic [String] The unique Salesforce Topic name
      # @param handler [Object] An object that responds to .call(message)
      # @param message [Hash] The event payload
      def call(topic, handler, message)
        if handler.respond_to? :perform_async
          handler.perform_async message
        else
          handler.call message
        end
        ReplayPersistence.record topic, message.dig('event', 'replayId')
      rescue StandardError => e
        Configuration.instance.exception_adapter.call e
      end
    end
  end
end
