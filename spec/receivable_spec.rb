require "spec_helper"
require "cf/interface/receivable"
require "cf/interface/interface"

describe CF::Interface::Receivable do
  it "inverts control to publish itself as a message on an interface" do
    receiving_class = Class.new do
      extend CF::Interface::Receivable
    end
    interface = double(::CF::Interface::Interface)

    receiver = receiving_class.new
    interface.should_receive(:on_receive).with(receiving_class).and_yield(receiver)
    called = false
    receiving_class.on_receive(interface) do |arg|
      expect(arg).to eq(receiver)
      called = true
    end
    expect(called).to eq(true)
  end
end
