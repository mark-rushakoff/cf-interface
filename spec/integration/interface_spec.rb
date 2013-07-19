require "spec_helper"
require "cf/interface/interface"
require "cf_message_bus/mock_message_bus"

describe CF::Interface::Interface do
  let(:message_bus) { CfMessageBus::MockMessageBus.new }
  subject(:interface) { described_class.new(message_bus) }
end
