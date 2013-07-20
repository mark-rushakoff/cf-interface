require "cf/interface/receivable"
require "cf/interface/broadcastable"

module CF::Interface
  DropletUpdatedMessage = Struct.new(:app_guid, :cc_partition) do
    # taken from VCAP::CloudController::HealthManagerClient#notify_app_updated
    include Broadcastable
    extend Receivable

    def serialize
      {
        droplet: app_guid,
        cc_partition: cc_partition
      }.to_json
    end

    def valid?
      warn "Defaulting valid to true..."
      true
    end

    class << self
      def deserialize(serialized)
        parsed = JSON.parse(serialized)
        new(parsed.fetch("droplet"), parsed.fetch("cc_partition"))
      end

      def channel
        "droplet.updated"
      end
    end
  end
end
