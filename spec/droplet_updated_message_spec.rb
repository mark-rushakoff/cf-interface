require "spec_helper"
require "cf/interface/droplet_updated_message"

describe CF::Interface::DropletUpdatedMessage do
  describe "serialization" do
    it "can round trip properly" do
      original = described_class.new("an app guid", "a partition")
      clone = described_class.deserialize(original.serialize)

      expect(original).not_to equal(clone)
      expect(clone.app_guid).to eq("an app guid")
      expect(clone.cc_partition).to eq("a partition")
    end
  end
end
