module SalesforceStreamer
  # Models the PushTopic object for both Restforce and Streamer
  class PushTopic
    attr_accessor :id
    attr_reader :name, :description, :notify_for_fields, :query,
      :handler, :handler_constant, :api_version

    def initialize(data:)
      @handler = data['handler']
      @static_replay = data.dig('replay')&.to_i || -1
      @name = data.dig('salesforce', 'name')
      @api_version = data.dig('salesforce', 'api_version') || '41.0'
      @description = data.dig('salesforce', 'description') || @name
      @notify_for_fields = data.dig('salesforce', 'notify_for_fields') || 'Referenced'
      @query = strip_spaces(data.dig('salesforce', 'query'))
      validate!
    end

    def replay
      ReplayPersistence.retrieve(name) || @static_replay
    end

    def handle(message)
      handle_chain.call(message)
      ReplayPersistence.record @name, message.dig('event', 'replayId')
    rescue StandardError => e
      Log.error e
      Configuration.instance.exception_adapter.call e
    end

    def to_s
      "PushTopic id=#{id} name=#{name} handler=#{handler} " \
        "replay=#{replay} notify_for_fields=#{notify_for_fields} " \
        "description=#{description} api_version=#{api_version} query=#{query}"
    end

    private

    def validate!
      fail(PushTopicNameTooLongError, @name) if @name.size > 25

      @handler_constant = Object.const_get(@handler)
      true
    rescue NameError, TypeError => e
      message = 'handler=' + @handler.to_s + ' exception=' + e.to_s
      raise(PushTopicHandlerMissingError, message)
    end

    def handle_chain
      Configuration.instance.middleware_chain_for(handler_proc)
    end

    def handler_proc
      if handler_constant.respond_to? :perform_async
        proc { |message| handler_constant.perform_async message }
      else
        handler_constant
      end
    end

    def strip_spaces(str)
      fail(NilQueryError, @name) unless str

      str.gsub(/\s+/, ' ')
    end
  end
end
