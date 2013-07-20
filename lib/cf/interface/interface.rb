require "cf_message_bus/message_bus"
require "cf/interface/serialization_error"

module CF::Interface
  class Interface
    def initialize(message_bus)
      @message_bus = message_bus
    end

    def connected?
      message_bus.connected?
    end

    def publish_message(message)
      raise SerializationError, "Message not valid for serialization: #{message.inspect}" unless message.valid?
      message_bus.publish(message.class.channel, message.serialize)
    end

    def on_receive(message_class)
      message_bus.subscribe(message_class.channel) do |serialized|
        begin
          yield message_class.deserialize(serialized), nil
        rescue
          yield nil, DeserializationError.new("Error deserializing")
        end
      end
    end

    private
    attr_reader :message_bus
  end
end
