require "spec_helper"
require "cf/interface/receivable"
require "cf/interface/interface"

describe CF::Interface::Receivable do
  it "can pass through the instance when yielded by the interface" do
    receiving_class = Class.new do
      extend CF::Interface::Receivable
    end
    interface = double(::CF::Interface::Interface)

    receiver = receiving_class.new
    interface.should_receive(:on_receive).with(receiving_class).and_yield(receiver, nil)
    called = false
    receiving_class.on_receive(interface) do |instance, error|
      expect(instance).to eq(receiver)
      expect(error).to be_nil
      called = true
    end
    expect(called).to eq(true)
  end

  it "can yield the error if the interface yields it" do
    receiving_class = Class.new do
      extend CF::Interface::Receivable
    end
    interface = double(::CF::Interface::Interface)

    error = double(::CF::Interface::DeserializationError)
    interface.should_receive(:on_receive).with(receiving_class).and_yield(nil, error)
    called = false
    receiving_class.on_receive(interface) do |instance, err|
      expect(instance).to be_nil
      expect(error).to equal(error)
      called = true
    end
    expect(called).to eq(true)
  end

  it "raises an exception if interface somehow yields nothing" do
    receiving_class = Class.new do
      extend CF::Interface::Receivable
    end
    interface = double(::CF::Interface::Interface)

    interface.should_receive(:on_receive).with(receiving_class).and_yield(nil, nil)
    expect {
      receiving_class.on_receive(interface) { |_, _| }
    }.to raise_error(::CF::Interface::BaseError, "This should never happen")
  end
end
