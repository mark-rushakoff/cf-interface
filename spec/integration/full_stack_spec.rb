require "spec_helper"
require "cf/interface"
require "cf/interface/collector_ping_message"
require "nats/client"
require "socket"

module ::CF::Interface::NatsHelper
  def start_nats
    @nats_thread = Thread.new do
      ARGV.clear
      ARGV.concat(%w(-a 127.0.0.1 -p 42220))
      require "nats/server"
    end
    wait_for_nats_to_start
  end

  def stop_nats
    @nats_thread.exit unless @nats_thread.nil?
  end

  def wait_for(seconds = 2)
    Timeout.timeout(seconds) do
      sleep 0.1
      redo unless yield
    end
  end

  def in_em
    EM.run do
      EM.defer(Proc.new { yield })
    end
  end

  def build_interface
    message_bus = CfMessageBus::MessageBus.new(uri: nats_uri)
    wait_for { message_bus.connected? }
    ::CF::Interface.new(message_bus)
  end

  private
  def nats_uri
    "nats://127.0.0.1:42220"
  end

  def wait_for_nats_to_start
    Timeout.timeout(5) do
      loop do
        begin
          s = TCPSocket.new("127.0.0.1", 42220)
          s.close
          sleep 0.1
          break
        rescue Errno::ECONNREFUSED
        end
      end
    end
  end
end

describe "The full stack" do
  describe "the interface object" do
    include ::CF::Interface::NatsHelper

    before(:all) { start_nats }
    after(:all) { stop_nats }

    it "can identify when it's connected to a real NATS server" do
      made_connection = false

      in_em do
        interface = build_interface

        expect(interface).to be_connected
        made_connection = true
      end

      wait_for { made_connection }

      expect(made_connection).to eq(true)
    end

    it "can do a basic pub/sub with a real message that serializes as non-JSON" do
      received_message = false

      in_em do
        interface = build_interface

        ::CF::Interface::CollectorPingMessage.on_receive(interface) do |message, error|
          expect(message.current_time.to_i).to eq(1)
          expect(error).to be_nil
          received_message = true
        end

        ping_message = ::CF::Interface::CollectorPingMessage.new(Time.at(1))
        ping_message.broadcast(interface)

        # without this wait, the EM loop will immediately exit and the receive callback won't happen
        wait_for(5) { received_message }
      end

      # without this wait, the outer loop will immediately exit without waiting for the EM loop
      wait_for(5) { received_message }
      expect(received_message).to eq(true)
    end
  end
end
