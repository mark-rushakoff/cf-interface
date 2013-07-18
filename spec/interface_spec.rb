require "spec_helper"
require "cf/interface"

describe CF::Interface do
  describe '.new' do
    it "is shorthand for directly creating an implementation of Interface" do
      message_bus = double(::CfMessageBus::MessageBus)
      an_interface = double(::CF::Interface::Interface)
      CF::Interface::Interface.should_receive(:new).with(message_bus).and_return(an_interface)

      expect(CF::Interface.new(message_bus)).to equal(an_interface)
    end
  end
end

describe CF::Interface::Interface do
  let(:message_bus) { double(::CfMessageBus::MessageBus) }
  subject(:interface) { described_class.new(message_bus) }

  it "exposes the message bus's connected? method" do
    message_bus.should_receive(:connected?).and_return("foobar")
    expect(interface.connected?).to eq("foobar")
  end

  describe "droplet_updated" do
    describe "#broadcast_droplet_updated" do
      let(:droplet_updated_message) { double(::CF::Interface::DropletUpdatedMessage) }

      it "publishes on the droplet.updated channel" do
        droplet_updated_message.stub(:serialize).and_return({foo: "bar"})
        message_bus.should_receive(:publish).with("droplet.updated", foo: "bar")
        interface.broadcast_droplet_updated(droplet_updated_message)
      end
    end

    describe "#on_droplet_updated" do
      it "subscribes to droplet.updated" do
        callback = Proc.new { |_| }
        message_bus.should_receive(:subscribe).with("droplet.updated", &callback)
        interface.on_droplet_updated(&callback)
      end
    end
  end
end
