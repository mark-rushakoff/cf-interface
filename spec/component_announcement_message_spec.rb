require "spec_helper"
require "cf_message_bus/mock_message_bus"
require "cf/interface"
require "cf/interface/component_announcement_message"

describe CF::Interface::ComponentAnnouncementMessage do
  subject(:message) do
    described_class.new(
      component_type: "component_type",
      index: 99,
      host: "192.0.2.1",
      credentials: {
        user: "a_username",
        password: "a_password"
      }
    )
  end

  it "has the right channel" do
    expect(described_class.channel).to eq("vcap.component.announce")
  end

  describe "with a message bus" do
    let(:message_bus) { ::CfMessageBus::MockMessageBus.new }
    let(:interface) { ::CF::Interface.new(message_bus) }

    it "can be transmitted" do
      interface = CF::Interface.new(CfMessageBus::MockMessageBus.new)

      received = false
      described_class.on_receive(interface) do |component_announcement_message|
        received = true
        expect(component_announcement_message.component_type).to eq("component_type")
        expect(component_announcement_message.index).to eq(99)
        expect(component_announcement_message.host).to eq("192.0.2.1")
        expect(component_announcement_message.credentials).to eq(
          user: "a_username",
          password: "a_password"
        )
      end

      message.broadcast(interface)
      expect(received).to eq(true)
    end
  end
end
