require "spec_helper"
require "cf/interface"
require "nats/client"
require "socket"

module ::CF::Interface::NatsHelper
  def with_nats_thread
    nats_thread = Thread.new do
      ARGV.clear
      ARGV.concat(%w(-a 127.0.0.1 -p 42220))
      require "nats/server"
    end
    wait_for_nats_to_start
    yield
  ensure
    nats_thread.exit unless nats_thread.nil?
  end

  def wait_for(seconds = 2)
    Timeout.timeout(seconds) do
      sleep 0.1
      redo unless yield
    end
  end

  def in_em
    EM.run do
      EM.defer(-> {
        yield
      },
      -> { EM.stop })
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

    it "can identify when it's connected to a real NATS server" do
      with_nats_thread do
        made_connection = false

        in_em do
          interface = build_interface

          expect(interface).to be_connected
          made_connection = true
        end

        wait_for { made_connection }

        expect(made_connection).to eq(true)
      end
    end
  end
end
