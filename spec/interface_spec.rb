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

  describe "#publish_message" do
    let(:fake_message_class) do
      Class.new do
        def self.channel
          "the_channel"
        end

        def serialize
          "serialized_data"
        end
      end
    end

    it "publishes the serialized message on the message's channel" do
      message_bus.should_receive(:publish).with("the_channel", "serialized_data")
      interface.publish_message(fake_message_class.new)
    end
  end

  describe "#on_receive" do
    let(:fake_message_class) do
      Class.new do
        def self.channel
          "the_channel"
        end

        def self.deserialize(str)
          str.upcase
        end
      end
    end

    it "subscribes to the class's channel and deserializes" do
      called = false
      blk = Proc.new do |deserialized|
        expect(deserialized).to eq("SOME TEXT")
        called = true
      end
      message_bus.should_receive(:subscribe).with("the_channel").and_yield("some text")
      interface.on_receive(fake_message_class, &blk)

      expect(called).to eq(true)
    end
  end
end
