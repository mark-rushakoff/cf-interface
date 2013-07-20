require "spec_helper"
require "cf/interface"
require "cf/interface/serialization_error"
require "cf/interface/deserialization_error"

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

        def valid?
          true
        end
      end
    end

    it "publishes the serialized message on the message's channel" do
      message_bus.should_receive(:publish).with("the_channel", "serialized_data")
      interface.publish_message(fake_message_class.new)
    end

    it "raises a SerializationError when the message is invalid" do
      invalid_message = fake_message_class.new
      invalid_message.stub(:valid? => false)

      expect {
        interface.publish_message(invalid_message)
      }.to raise_error(::CF::Interface::SerializationError)
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
      blk = Proc.new do |deserialized, error|
        expect(deserialized).to eq("SOME TEXT")
        expect(error).to be_nil
        called = true
      end
      message_bus.should_receive(:subscribe).with("the_channel").and_yield("some text")
      interface.on_receive(fake_message_class, &blk)

      expect(called).to eq(true)
    end

    it "yields an error when deserialization fails" do
      def fake_message_class.deserialize(_)
        raise "can't deserialize"
      end

      called = false
      blk = Proc.new do |deserialized, error|
        expect(deserialized).to be_nil
        expect(error).to be_a(::CF::Interface::DeserializationError)
        expect(error.original.message).to match("can't deserialize")
        called = true
      end
      message_bus.should_receive(:subscribe).with("the_channel").and_yield("some text")
      interface.on_receive(fake_message_class, &blk)

      expect(called).to eq(true)
    end
  end
end
