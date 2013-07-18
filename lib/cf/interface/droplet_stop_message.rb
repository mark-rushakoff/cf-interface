module CF::Interface
  DropletStopMessage = Struct.new(:app_guid) do
    # taken from VCAP::CloudController::DeaClient#dea_publish_stop
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
end
