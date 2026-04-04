require "rails_helper"

RSpec.describe KeepAliveControlMasterJob, type: :job do
  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  context "when no control_master SystemStatus record exists" do
    it "does nothing" do
      expect(ControlMasterService).not_to receive(:connected?)
      described_class.perform_now
    end
  end

  context "when status is not 'connected'" do
    before { SystemStatus.create!(name: "control_master", connected: false, status: "disconnected") }

    it "does not check the socket" do
      expect(ControlMasterService).not_to receive(:connected?)
      described_class.perform_now
    end
  end

  context "when status is 'connected' and socket is still alive" do
    before do
      SystemStatus.create!(name: "control_master", connected: true, status: "connected")
      allow(ControlMasterService).to receive(:connected?).and_return(true)
    end

    it "leaves the status unchanged" do
      described_class.perform_now
      expect(SystemStatus.find_by(name: "control_master").status).to eq("connected")
    end

    it "does not broadcast" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).not_to have_received(:broadcast_replace_to)
    end
  end

  context "when status is 'connected' but the socket has died" do
    before do
      SystemStatus.create!(name: "control_master", connected: true, status: "connected")
      allow(ControlMasterService).to receive(:connected?).and_return(false)
    end

    it "updates status to 'disconnected'" do
      described_class.perform_now
      record = SystemStatus.find_by(name: "control_master")
      expect(record.status).to eq("disconnected")
      expect(record.connected).to be(false)
    end

    it "broadcasts the updated indicator" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "system_status",
        target: "control_master_indicator",
        html: anything
      )
    end
  end
end
