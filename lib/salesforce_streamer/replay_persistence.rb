# frozen_string_literal: true

module SalesforceStreamer
  # Store values for a given key in a sorted sequence
  # Retrieves the highest value given a key
  class ReplayPersistence
    class << self
      def record(key, value)
        Log.debug { "Recording #{key}=value" }
        Configuration.instance.persistence_adapter&.record key, value
      end

      def retrieve(key)
        Configuration.instance.persistence_adapter&.retrieve(key).tap do |v|
        Log.debug { "Retrieved for #{key} #{ v || 'nil' }" }
        end
      end
    end
  end
end
