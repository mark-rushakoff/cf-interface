require "spec_helper"
require "cf/interface/droplet_stop_message"

describe CF::Interface::DropletStopMessage do
  describe "serialization" do
    it "can round trip properly" do
      original = described_class.new("an app guid")
      clone = described_class.deserialize(original.serialize)

      expect(original).not_to equal(clone)
      expect(clone.app_guid).to eq("an app guid")
    end
  end
end
