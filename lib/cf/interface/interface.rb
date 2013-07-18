require "cf_message_bus/message_bus"

module CF::Interface
  class Interface
    def initialize(message_bus)
      @message_bus = message_bus
    end

    def connected?
      @message_bus.connected?
    end
  end
end
