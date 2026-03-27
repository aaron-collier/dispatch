require "rails_helper"

RSpec.describe SystemStatus, type: :model do
  describe "validations" do
    it "is valid with a name and connected value" do
      status = described_class.new(name: "vpn", connected: false)
      expect(status).to be_valid
    end

    it "is invalid without a name" do
      status = described_class.new(name: nil, connected: false)
      expect(status).not_to be_valid
    end

    it "is invalid with a duplicate name" do
      described_class.create!(name: "vpn", connected: false)
      duplicate = described_class.new(name: "vpn", connected: true)
      expect(duplicate).not_to be_valid
    end
  end

  describe ".for" do
    it "returns an existing record by name" do
      existing = described_class.create!(name: "vpn", connected: true)
      expect(described_class.for("vpn")).to eq(existing)
    end

    it "initializes a new record when none exists" do
      record = described_class.for("control_master")
      expect(record).to be_a_new(described_class)
      expect(record.name).to eq("control_master")
    end
  end
end
