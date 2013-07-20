require "cf/interface/receivable"
require "cf/interface/broadcastable"

module CF::Interface
  DropletStopMessage = Struct.new(:app_guid) do
    # taken from VCAP::CloudController::DeaClient#stop
    include Broadcastable
    extend Receivable

    def serialize
      {
        droplet: app_guid
      }.to_json
    end

    def valid?
      warn "Defaulting valid? to true..."
      true
    end

    class << self
      def deserialize(serialized)
        parsed = JSON.parse(serialized)
        new(parsed.fetch("droplet"))
      end

      def channel
        "dea.stop"
      end
    end
  end
end
