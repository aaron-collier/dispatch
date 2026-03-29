require "rails_helper"

RSpec.describe CheckAuthJob, type: :job do
  describe "#perform" do
    before do
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      allow(ApplicationController).to receive(:render).and_return("<div></div>")
    end

    context "when auth status does not exist" do
      it "does nothing" do
        described_class.perform_now
        expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
      end
    end

    context "when auth is active (not expired)" do
      before do
        SystemStatus.create!(name: "auth", connected: true, expires_at: 1.hour.from_now)
      end

      it "does not change the status" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "auth").connected).to be(true)
      end

      it "does not broadcast" do
        described_class.perform_now
        expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
      end
    end

    context "when auth has expired" do
      before do
        SystemStatus.create!(name: "auth", connected: true, expires_at: 1.hour.ago)
      end

      it "sets connected: false on the SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "auth").connected).to be(false)
      end

      it "broadcasts a replace turbo stream to system_status" do
        described_class.perform_now
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          "system_status",
          target: "auth_indicator",
          html: anything
        )
      end

      it "does not create a duplicate SystemStatus record" do
        expect { described_class.perform_now }.not_to change(SystemStatus, :count)
      end
    end

    context "when auth is disconnected with no expires_at" do
      before do
        SystemStatus.create!(name: "auth", connected: false, expires_at: nil)
      end

      it "does nothing" do
        described_class.perform_now
        expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
      end
    end
  end
end
