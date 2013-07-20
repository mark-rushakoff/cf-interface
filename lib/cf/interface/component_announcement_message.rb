require "cf/interface/receivable"
require "cf/interface/broadcastable"

module CF::Interface
  class ComponentAnnouncementMessage
    # taken from VCAP::CloudController::Collector#process_component_discover
    include Broadcastable
    extend Receivable

    attr_accessor :component_type, :index, :host, :credentials
    def initialize(opts)
      opts = opts.dup
      @component_type = opts.delete(:component_type)
      @index = opts.delete(:index)
      @host = opts.delete(:host)
      @credentials = opts.delete(:credentials)
    end

    def serialize
      {
        type: component_type,
        index: index,
        host: host,
        credentials: credentials
      }.to_json
    end

    class << self
      def deserialize(serialized)
        parsed = JSON.parse(serialized)
        new(
          component_type: parsed["type"],
          index: parsed["index"],
          host: parsed["host"],
          credentials: {
            user: parsed["credentials"]["user"],
            password: parsed["credentials"]["password"],
          }
        )
      end

      def channel
        "vcap.component.announce"
      end
    end
  end
end
