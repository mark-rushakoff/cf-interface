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
      raise ArgumentError.new("unknown options: #{opts.keys.join(", ")}") unless opts.empty?
    end

    def valid?
      !(component_type.nil? || index.nil? || host.nil? ||
        credentials.nil? || !credentials.has_key?(:user) || !credentials.has_key?(:password))
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
          component_type: parsed.fetch("type"),
          index: parsed.fetch("index"),
          host: parsed.fetch("host"),
          credentials: {
            user: parsed.fetch("credentials").fetch("user"),
            password: parsed.fetch("credentials").fetch("password")
          }
        )
      end

      def channel
        "vcap.component.announce"
      end
    end
  end
end
