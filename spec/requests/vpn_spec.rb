require "rails_helper"

RSpec.describe "Vpn", type: :request do
  before do
    allow(VpnService).to receive(:open)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  describe "POST /vpn/connect" do
    it "opens Cisco Secure Client" do
      allow(VpnService).to receive(:connected?).and_return(false)
      post connect_vpn_path
      expect(VpnService).to have_received(:open)
    end

    it "responds with a turbo stream" do
      allow(VpnService).to receive(:connected?).and_return(false)
      post connect_vpn_path
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end

    context "when VPN is not yet connected after opening" do
      it "does not mark status as connected" do
        allow(VpnService).to receive(:connected?).and_return(false)
        SystemStatus.create!(name: "vpn", connected: false, status: "disconnected")
        post connect_vpn_path
        expect(SystemStatus.find_by(name: "vpn").connected).to be(false)
      end
    end

    context "when VPN is connected after opening" do
      it "marks status as connected" do
        allow(VpnService).to receive(:connected?).and_return(true)
        SystemStatus.create!(name: "vpn", connected: false, status: "disconnected")
        post connect_vpn_path
        expect(SystemStatus.find_by(name: "vpn").connected).to be(true)
      end
    end
  end
end
