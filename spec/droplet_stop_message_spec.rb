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

describe CF::Interface::DropletStopInstancesMessage do
  describe "serialization" do
    it "can round trip properly" do
      original = described_class.new("an app guid", %w(instance-guid1 instance-guid2))
      clone = described_class.deserialize(original.serialize)

      expect(original).not_to equal(clone)
      expect(clone.app_guid).to eq("an app guid")
      expect(clone.instance_guids).to eq(%w(instance-guid1 instance-guid2))
    end
  end
end

describe CF::Interface::DropletStopIndicesMessage do
  describe "serialization" do
    it "can round trip properly" do
      original = described_class.new("an app guid", "app version", [3, 4])
      clone = described_class.deserialize(original.serialize)

      expect(original).not_to equal(clone)
      expect(clone.app_guid).to eq("an app guid")
      expect(clone.app_version).to eq("app version")
      expect(clone.instance_indices).to eq([3, 4])
    end
  end
end
