require "spec_helper"

describe CF::Interface do
  it "has a version" do
    expect(described_class::VERSION).not_to be_nil
  end
end
