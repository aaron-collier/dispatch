require "rails_helper"

RSpec.describe KeepAliveVpnJob, type: :job do
  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  context "when VPN was disconnected and is still disconnected" do
    before do
      SystemStatus.create!(name: "vpn", connected: false, status: "disconnected")
      allow(VpnService).to receive(:connected?).and_return(false)
    end

    it "does not change the status" do
      described_class.perform_now
      expect(SystemStatus.find_by(name: "vpn").status).to eq("disconnected")
    end

    it "does not broadcast" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
    end
  end

  context "when VPN was connected and is still connected" do
    before do
      SystemStatus.create!(name: "vpn", connected: true, status: "connected")
      allow(VpnService).to receive(:connected?).and_return(true)
    end

    it "does not change the status" do
      described_class.perform_now
      expect(SystemStatus.find_by(name: "vpn").status).to eq("connected")
    end

    it "does not broadcast" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
    end
  end

  context "when VPN was disconnected and has now connected" do
    before do
      SystemStatus.create!(name: "vpn", connected: false, status: "disconnected")
      allow(VpnService).to receive(:connected?).and_return(true)
    end

    it "updates status to 'connected'" do
      described_class.perform_now
      record = SystemStatus.find_by(name: "vpn")
      expect(record.status).to eq("connected")
      expect(record.connected).to be(true)
    end

    it "broadcasts the updated indicator" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "system_status",
        target: "vpn_indicator",
        html: anything
      )
    end
  end

  context "when VPN was connected but has dropped" do
    before do
      SystemStatus.create!(name: "vpn", connected: true, status: "connected")
      allow(VpnService).to receive(:connected?).and_return(false)
    end

    it "updates status to 'disconnected'" do
      described_class.perform_now
      record = SystemStatus.find_by(name: "vpn")
      expect(record.status).to eq("disconnected")
      expect(record.connected).to be(false)
    end

    it "broadcasts the updated indicator" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "system_status",
        target: "vpn_indicator",
        html: anything
      )
    end
  end

  context "when no VPN SystemStatus record exists yet" do
    before do
      allow(VpnService).to receive(:connected?).and_return(false)
    end

    it "does not broadcast (new record has nil connected, matching false)" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
    end
  end
end
