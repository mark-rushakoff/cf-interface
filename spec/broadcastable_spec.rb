require "spec_helper"
require "cf/interface/broadcastable"
require "cf/interface/interface"

describe CF::Interface::Broadcastable do
  it "inverts control to publish itself as a message on an interface" do
    broadcasting_class = Class.new do
      include CF::Interface::Broadcastable
    end
    interface = double(::CF::Interface::Interface)

    broadcaster = broadcasting_class.new
    interface.should_receive(:publish_message).with(broadcaster)
    broadcaster.broadcast(interface)
  end
end
