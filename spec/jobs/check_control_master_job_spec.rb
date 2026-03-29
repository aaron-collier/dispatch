require "rails_helper"

RSpec.describe CheckControlMasterJob, type: :job do
  describe "#perform" do
    before do
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      allow(ApplicationController).to receive(:render).and_return("<div></div>")
    end

    context "when a control master session is open" do
      before do
        allow(Settings).to receive(:control_master_host).and_return("deploy.example.com")
        allow_any_instance_of(described_class).to receive(:system).and_return(true)
      end

      it "saves connected: true to SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "control_master").connected).to be(true)
      end

      it "broadcasts a replace turbo stream to system_status" do
        described_class.perform_now
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          "system_status",
          target: "control_master_indicator",
          html: anything
        )
      end
    end

    context "when no control master session is open" do
      before do
        allow_any_instance_of(described_class).to receive(:system).and_return(false)
      end

      it "saves connected: false to SystemStatus" do
        described_class.perform_now
        expect(SystemStatus.find_by(name: "control_master").connected).to be(false)
      end
    end

    context "when control_master_host is blank" do
      before do
        allow(Settings).to receive(:control_master_host).and_return("")
      end

      it "saves connected: false without calling ssh" do
        expect_any_instance_of(described_class).not_to receive(:system)
        described_class.perform_now
        expect(SystemStatus.find_by(name: "control_master").connected).to be(false)
      end
    end

    it "updates an existing SystemStatus record rather than creating a duplicate" do
      SystemStatus.create!(name: "control_master", connected: true)
      allow_any_instance_of(described_class).to receive(:system).and_return(false)

      expect { described_class.perform_now }.not_to change(SystemStatus, :count)
      expect(SystemStatus.find_by(name: "control_master").connected).to be(false)
    end
  end
end
