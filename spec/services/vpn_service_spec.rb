require "rails_helper"

RSpec.describe VpnService do
  describe ".connected?" do
    context "when a utun interface is present" do
      before do
        allow(described_class).to receive(:`).and_return("utun0: flags=8051\nlo0: flags=8049\n")
      end

      it "returns true" do
        expect(described_class.connected?).to be(true)
      end
    end

    context "when no utun interface is present" do
      before do
        allow(described_class).to receive(:`).and_return("lo0: flags=8049\nen0: flags=8863\n")
      end

      it "returns false" do
        expect(described_class.connected?).to be(false)
      end
    end
  end

  describe ".open" do
    it "launches Cisco Secure Client" do
      allow(described_class).to receive(:system)
      described_class.open
      expect(described_class).to have_received(:system).with("open", "-a", "Cisco Secure Client")
    end
  end
end
