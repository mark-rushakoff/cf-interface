require "cf_message_bus/message_bus"

module CF::Interface
  class Interface
    def initialize(message_bus)
      @message_bus = message_bus
    end

    def connected?
      message_bus.connected?
    end

    def publish_message(message)
      message_bus.publish(message.class.channel, message.serialize)
    end

    def on_receive(message_class, &blk)
      message_bus.subscribe(message_class.channel) do |serialized|
        blk.call(message_class.deserialize(serialized))
      end
    end

    private
    attr_reader :message_bus
  end
end
