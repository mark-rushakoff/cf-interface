require "spec_helper"
require "cf/interface/droplet_stop_message"

describe CF::Interface::DropletStopMessage do
  subject(:message) { described_class.new("an app guid") }

  it "has the right channel" do
    expect(described_class.channel).to eq("dea.stop")
  end

  describe "with a message bus" do
    let(:message_bus) { ::CfMessageBus::MockMessageBus.new }
    let(:interface) { ::CF::Interface.new(message_bus) }

    it "can be transmitted" do
      interface = CF::Interface.new(CfMessageBus::MockMessageBus.new)

      received = false
      described_class.on_receive(interface) do |droplet_stop_message|
        received = true
        expect(droplet_stop_message.app_guid).to eq("an app guid")
      end

      message.broadcast(interface)
      expect(received).to eq(true)
    end
  end
end
