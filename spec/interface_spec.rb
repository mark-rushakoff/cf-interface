require "spec_helper"
require "cf/interface/interface"

describe CF::Interface::Interface do
  let(:message_bus) { double(::CfMessageBus::MessageBus) }

  it "exposes the message bus's connected? method" do
    message_bus.should_receive(:connected?).and_return("foobar")
    expect(described_class.new(message_bus).connected?).to eq("foobar")
  end
end
