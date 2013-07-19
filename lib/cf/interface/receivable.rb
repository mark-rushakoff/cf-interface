module CF::Interface
  module Receivable
    def on_receive(interface)
      interface.on_receive(self) do |instance|
        yield instance
      end
    end
  end
end
