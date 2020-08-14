module SalesforceStreamer
  # Models the PushTopic object for both Restforce and Streamer
  class PushTopic
    extend Dry::Initializer

    option :name
    option :query, proc { |str| str.gsub(/\s+/, ' ') }
    option :handler, proc { |str| prepare_handler_proc Object.const_get(str) }
    option :replay, proc(&:to_i), default: proc { -1 }
    option :api_version, proc(&:to_s), default: proc { '49.0' }
    option :notify_for_fields, default: proc { 'Referenced' }
    option :id, optional: true
    option :description, optional: true

    attr_writer :id

    def handle(message)
      message['topic'] = @name
      message_middleware.call(message)
    rescue StandardError => e
      Log.error e
      Configuration.instance.exception_adapter.call e
    end

    def attributes
      self.class.dry_initializer.public_attributes self
    end

    private

    def validate!
      fail(PushTopicNameTooLongError, @name) if @name.size > 25

      @handler = Object.const_get(@handler)
      true
    rescue NameError, TypeError => e
      message = 'handler=' + @handler.to_s + ' exception=' + e.to_s
      raise(PushTopicHandlerMissingError, message)
    end

    def message_middleware
      Configuration.instance.middleware_runner(handler)
    end

    class << self
      def strip_spaces(str)
        fail(NilQueryError, @name) unless str

        str.gsub(/\s+/, ' ')
      end

      def prepare_handler_proc(constant)
        if constant.respond_to? :call
          constant
        elsif constant.respond_to? :perform_async
          proc { |message| constant.perform_async message }
        else
          fail(UnprocessableHandlerError, constant)
        end
      end
    end
  end
end
