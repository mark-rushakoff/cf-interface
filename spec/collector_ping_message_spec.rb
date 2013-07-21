require "spec_helper"
require "cf_message_bus/mock_message_bus"
require "cf/interface"
require "cf/interface/collector_ping_message"

describe CF::Interface::CollectorPingMessage do
  let(:current_time_float) { 1374365100.9837341 }
  subject(:message) { described_class.new(Time.at(current_time_float)) }

  it "has the right channel" do
    expect(described_class.channel).to eq("collector.nats.ping")
  end

  describe "#valid?" do
    it "is true when current_time is a Time" do
      expect(message).to be_valid
    end

    it "is false when current_time is nil" do
      message.current_time = nil
      expect(message).to_not be_valid
    end
  end

  describe "malformed serializations" do
    it "raises if the string can't be parsed as a float" do
      expect {
        described_class.deserialize("word")
      }.to raise_error(/word/)
    end
  end

  describe "with a message bus" do
    let(:message_bus) { ::CfMessageBus::MockMessageBus.new }
    let(:interface) { ::CF::Interface.new(message_bus) }

    it "can be transmitted" do
      interface = CF::Interface.new(CfMessageBus::MockMessageBus.new)

      received = false
      described_class.on_receive(interface) do |collector_ping_message, error|
        expect(error).to be_nil
        expect(collector_ping_message.current_time).to eq(Time.at(current_time_float))
        received = true
      end

      message.broadcast(interface)
      expect(received).to eq(true)
    end
  end
end
