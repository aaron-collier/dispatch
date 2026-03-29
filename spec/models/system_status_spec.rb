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

  describe "#expired?" do
    it "returns false when expires_at is nil" do
      status = described_class.new(name: "auth", connected: true, expires_at: nil)
      expect(status.expired?).to be(false)
    end

    it "returns false when expires_at is in the future" do
      status = described_class.new(name: "auth", connected: true, expires_at: 1.hour.from_now)
      expect(status.expired?).to be(false)
    end

    it "returns true when expires_at is in the past" do
      status = described_class.new(name: "auth", connected: true, expires_at: 1.hour.ago)
      expect(status.expired?).to be(true)
    end
  end

  describe "#active?" do
    it "returns true when connected and not expired" do
      status = described_class.new(name: "auth", connected: true, expires_at: 1.hour.from_now)
      expect(status.active?).to be(true)
    end

    it "returns false when connected but expired" do
      status = described_class.new(name: "auth", connected: true, expires_at: 1.hour.ago)
      expect(status.active?).to be(false)
    end

    it "returns false when disconnected regardless of expiry" do
      status = described_class.new(name: "auth", connected: false, expires_at: 1.hour.from_now)
      expect(status.active?).to be(false)
    end

    it "returns true when connected with no expires_at" do
      status = described_class.new(name: "vpn", connected: true, expires_at: nil)
      expect(status.active?).to be(true)
    end
  end
end
