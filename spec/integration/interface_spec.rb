require "spec_helper"
require "cf/interface/interface"
require "cf_message_bus/mock_message_bus"

describe CF::Interface::Interface do
  let(:message_bus) { CfMessageBus::MockMessageBus.new }
  subject(:interface) { described_class.new(message_bus) }

  it "can serialize and deserialize a droplet updated message" do
    received = false
    message = ::CF::Interface::DropletUpdatedMessage.new("an app guid", "a partition")

    interface.on_droplet_updated do |droplet_updated_message|
      expect(droplet_updated_message.app_guid).to eq("an app guid")
      expect(droplet_updated_message.cc_partition).to eq("a partition")
      received = true
    end

    interface.broadcast_droplet_updated(message)

    expect(received).to eq(true)
  end
end
