require "rails_helper"

RSpec.describe CheckVpnJob, type: :job do
  describe "#perform" do
    before do
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      allow(ApplicationController).to receive(:render).and_return("<div></div>")
    end

    context "when VPN is connected (utun interface present)" do
      before do
        allow_any_instance_of(described_class).to receive(:`).and_return("utun0: flags=8051\nlo0: flags=8049\n")
      end

      it "saves connected: true to SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "vpn").connected).to be(true)
      end

      it "broadcasts a replace turbo stream to system_status" do
        described_class.perform_now
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          "system_status",
          target: "vpn_indicator",
          html: anything
        )
      end
    end

    context "when VPN is disconnected (no utun interface)" do
      before do
        allow_any_instance_of(described_class).to receive(:`).and_return("lo0: flags=8049\nen0: flags=8863\n")
      end

      it "saves connected: false to SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "vpn").connected).to be(false)
      end
    end

    it "updates an existing SystemStatus record rather than creating a duplicate" do
      SystemStatus.create!(name: "vpn", connected: true)
      allow_any_instance_of(described_class).to receive(:`).and_return("lo0: flags=8049\n")

      expect { described_class.perform_now }.not_to change(SystemStatus, :count)
      expect(SystemStatus.find_by(name: "vpn").connected).to be(false)
    end
  end
end
