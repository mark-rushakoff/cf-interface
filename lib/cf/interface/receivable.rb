require "cf/interface/base_error"

module CF::Interface
  module Receivable
    def on_receive(interface)
      interface.on_receive(self) do |instance, error|
        raise BaseError.new("This should never happen") if instance.nil? && error.nil?
        yield instance, error
      end
    end
  end
end
