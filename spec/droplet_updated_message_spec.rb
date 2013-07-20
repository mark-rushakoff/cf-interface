require "spec_helper"
require "cf_message_bus/mock_message_bus"
require "cf/interface"
require "cf/interface/droplet_updated_message"

describe CF::Interface::DropletUpdatedMessage do
  subject(:message) { described_class.new("an app guid", "a partition") }

  it "has the right channel" do
    expect(described_class.channel).to eq("droplet.updated")
  end

  describe "#valid?" do
    it "is true when app_guid and cc_partition are not nil" do
      expect(message).to be_valid
    end

    it "is false when app_guid is nil" do
      message.app_guid = nil
      expect(message).to_not be_valid
    end

    it "is false when cc_partition is nil" do
      message.cc_partition = nil
      expect(message).to_not be_valid
    end
  end

  describe "malformed serializations" do
    it "raises if the key 'droplet' is missing" do
      expect {
        described_class.deserialize({cc_partition: "foo"}.to_json)
      }.to raise_error(/droplet/)
    end

    it "raises if the key 'cc_partition' is missing" do
      expect {
        described_class.deserialize({droplet: "foo"}.to_json)
      }.to raise_error(/cc_partition/)
    end

    it "raises if given invalid JSON" do
      expect {
        described_class.deserialize(":)")
      }.to raise_error
    end
  end

  describe "with a message bus" do
    let(:message_bus) { ::CfMessageBus::MockMessageBus.new }
    let(:interface) { ::CF::Interface.new(message_bus) }

    it "can be transmitted" do
      interface = CF::Interface.new(CfMessageBus::MockMessageBus.new)

      received = false
      described_class.on_receive(interface) do |droplet_updated_message|
        received = true
        expect(droplet_updated_message.app_guid).to eq("an app guid")
        expect(droplet_updated_message.cc_partition).to eq("a partition")
      end

      message.broadcast(interface)
      expect(received).to eq(true)
    end
  end
end
