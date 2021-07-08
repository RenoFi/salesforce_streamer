class PushTopicFactory
  class << self
    def make(attributes = {})
      default_arguments = {
        name: 'TestHandlerTopic',
        handler: 'TestHandlerClass',
        query: 'SELECT Id FROM Lead'
      }
      SalesforceStreamer::PushTopic.new(**default_arguments.merge(attributes))
    end
  end
end
