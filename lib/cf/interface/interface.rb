require "cf_message_bus/message_bus"
require "cf/interface/droplet_updated_message"

module CF::Interface
  class Interface
    def initialize(message_bus)
      @message_bus = message_bus
    end

    def connected?
      message_bus.connected?
    end

    def on_droplet_updated(&blk)
      message_bus.subscribe("droplet.updated") do |serialized_message|
        message = ::CF::Interface::DropletUpdatedMessage.deserialize(serialized_message)
        blk.call(message)
      end
    end

    def broadcast_droplet_updated(droplet_updated_message)
      message_bus.publish("droplet.updated", droplet_updated_message.serialize)
    end

    private
    attr_reader :message_bus
  end
end
