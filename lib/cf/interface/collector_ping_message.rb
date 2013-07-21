require "cf/interface/receivable"
require "cf/interface/broadcastable"

module CF::Interface
  CollectorPingMessage = Struct.new(:current_time) do
    # taken from Collector::Collector#process_nats_ping
    include Broadcastable
    extend Receivable

    def serialize
      current_time.to_f.to_s
    end

    def valid?
      current_time.is_a?(Time)
    end

    class << self
      def deserialize(serialized)
        new(Time.at(Float(serialized)))
      end

      def channel
        "collector.nats.ping"
      end
    end
  end
end
