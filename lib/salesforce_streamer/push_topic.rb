# frozen_string_literal: true

module SalesforceStreamer
  # Models the PushTopic object for both Restforce and Streamer
  class PushTopic
    attr_accessor :id
    attr_reader :name, :replay, :description, :notify_for_fields, :query,
      :handler, :handler_constant, :api_version

    def initialize(data:)
      @handler           = data['handler']
      @replay            = data.dig('replay')&.to_i || -1
      @name              = data.dig('salesforce', 'name')
      @api_version       = data.dig('salesforce', 'api_version') || '41.0'
      @description       = data.dig('salesforce', 'description') || @name
      @notify_for_fields = data.dig('salesforce', 'notify_for_fields') || 'Referenced'
      @query             = strip_spaces(data.dig('salesforce', 'query'))
      validate!
    end

    def to_s
      "PushTopic id=#{id} name=#{name} handler=#{handler} " \
        "replay=#{replay} notify_for_fields=#{notify_for_fields} " \
        "description=#{description} api_version=#{api_version} query=#{query}"
    end

    private

    def validate!
      raise(PushTopicNameTooLongError, @name) if @name.size > 25
      @handler_constant = Object.const_get(@handler)
      true
    rescue NameError, TypeError => e
      message = 'handler=' + @handler.to_s + ' exception=' + e.to_s
      raise(PushTopicHandlerMissingError, message)
    end

    def strip_spaces(str)
      raise(NilQueryError, @name) unless str
      str.gsub(/\s+/, ' ')
    end
  end
end
