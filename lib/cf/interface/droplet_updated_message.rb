module CF::Interface
  DropletUpdatedMessage = Struct.new(:app_guid, :cc_partition) do
    # taken from VCAP::CloudController::HealthManagerClient#notify_app_updated
    def serialize
      {
        droplet: app_guid,
        cc_partition: cc_partition
      }.to_json
    end

    def self.deserialize(serialized)
      parsed = JSON.parse(serialized)
      new(parsed.fetch("droplet"), parsed.fetch("cc_partition"))
    end
  end
end
