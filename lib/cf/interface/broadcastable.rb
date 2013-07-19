module CF::Interface
  module Broadcastable
    def broadcast(interface)
      interface.publish_message(self)
    end
  end
end
