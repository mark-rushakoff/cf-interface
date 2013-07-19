module CF::Interface
  DropletStopMessage = Struct.new(:app_guid) do
    # taken from VCAP::CloudController::DeaClient#stop
    def serialize
      {
        droplet: app_guid
      }.to_json
    end

    def broadcast(interface)
      interface.publish_message(self)
    end

    class << self
      def deserialize(serialized)
        parsed = JSON.parse(serialized)
        new(parsed.fetch("droplet"))
      end

      def on_receive(interface, &blk)
        interface.on_receive(self) do |instance|
          blk.call(instance)
        end
      end

      def channel
        "dea.stop"
      end
    end
  end
end
