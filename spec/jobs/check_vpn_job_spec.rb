require "rails_helper"

RSpec.describe CheckVpnJob, type: :job do
  describe "#perform" do
    before do
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      allow(ApplicationController).to receive(:render).and_return("<div></div>")
    end

    context "when a VPN connection is active" do
      before do
        allow_any_instance_of(described_class).to receive(:`).and_return(
          "Available network connection services in the current set (* = enabled):\n" \
          " *  (Connected) ABC123 com.cisco.anyconnect.vpn : anyconnect\n"
        )
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

    context "when no VPN connection is active" do
      before do
        allow_any_instance_of(described_class).to receive(:`).and_return(
          "Available network connection services in the current set (* = enabled):\n" \
          " *  (Disconnected) ABC123 com.cisco.anyconnect.vpn : anyconnect\n"
        )
      end

      it "saves connected: false to SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "vpn").connected).to be(false)
      end
    end

    context "when no VPN profiles are configured" do
      before do
        allow_any_instance_of(described_class).to receive(:`).and_return("")
      end

      it "saves connected: false to SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "vpn").connected).to be(false)
      end
    end

    it "updates an existing SystemStatus record rather than creating a duplicate" do
      SystemStatus.create!(name: "vpn", connected: true)
      allow_any_instance_of(described_class).to receive(:`).and_return("")

      expect { described_class.perform_now }.not_to change(SystemStatus, :count)
      expect(SystemStatus.find_by(name: "vpn").connected).to be(false)
    end
  end
end
