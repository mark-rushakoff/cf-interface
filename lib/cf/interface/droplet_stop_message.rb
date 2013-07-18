module CF::Interface
  DropletStopMessage = Struct.new(:app_guid) do
    # taken from VCAP::CloudController::DeaClient#stop
    def serialize
      {
        droplet: app_guid
      }.to_json
    end

    def self.deserialize(serialized)
      parsed = JSON.parse(serialized)
      new(parsed.fetch("droplet"))
    end
  end

  DropletStopInstancesMessage = Struct.new(:app_guid, :instance_guids) do
    # taken from VCAP::CloudController::DeaClient#stop_instances
    def serialize
      {
        droplet: app_guid,
        instances: instance_guids
      }.to_json
    end

    def self.deserialize(serialized)
      parsed = JSON.parse(serialized)
      new(parsed.fetch("droplet"), parsed.fetch("instances"))
    end
  end

  DropletStopIndicesMessage = Struct.new(:app_guid, :app_version, :instance_indices) do
    # taken from VCAP::CloudController::DeaClient#stop_indices
    def serialize
      {
        droplet: app_guid,
        version: app_version,
        indices: instance_indices
      }.to_json
    end

    def self.deserialize(serialized)
      parsed = JSON.parse(serialized)
      new(
        parsed.fetch("droplet"),
        parsed.fetch("version"),
        parsed.fetch("indices")
      )
    end
  end
end
