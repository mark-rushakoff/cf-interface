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

  let(:valid_serialization_hash) do
    {
      type: "type",
      index: 0,
      host: "192.0.2.1",
      credentials: {
        user: "user",
        password: "password"
      }
    }
  end

  it "has the right channel" do
    expect(described_class.channel).to eq("vcap.component.announce")
  end

  it "raises if initialized with unknown keys" do
    expect {
      described_class.new(
        some_unknown_key: "foo"
      )
    }.to raise_error(ArgumentError, /some_unknown_key/)
  end

  describe "#is_valid?" do
    it "is true for the valid serialization" do
      valid_obj = described_class.deserialize(valid_serialization_hash.to_json)
      expect(valid_obj).to be_valid
    end

    %w(component_type index host credentials).each do |key|
      it "is false if the attr '#{key}' is nil" do
        message.public_send("#{key}=", nil)
        expect(message).to_not be_valid
      end
    end

    it "is false when credentials[:user] is nil" do
      message.credentials.delete(:user)
      expect(message).to_not be_valid
    end

    it "is false when credentials[:password] is nil" do
      message.credentials.delete(:user)
      expect(message).to_not be_valid
    end
  end

  describe "malformed serializations" do
    %w(type index host credentials).each do |key|
      it "raises if the key '#{key}' is missing" do
        invalid_hash = valid_serialization_hash.dup
        invalid_hash.delete(key.to_sym)
        expect {
          described_class.deserialize(invalid_hash.to_json)
        }.to raise_error(/#{key}/)
      end
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
