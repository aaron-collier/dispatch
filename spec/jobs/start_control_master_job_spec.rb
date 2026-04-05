require "rails_helper"

RSpec.describe StartControlMasterJob, type: :job do
  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  context "when the control master connects successfully" do
    before { allow(ControlMasterService).to receive(:start).and_return(true) }

    it "saves status 'connected' to SystemStatus" do
      described_class.perform_now
      record = SystemStatus.find_by(name: "control_master")
      expect(record.status).to eq("connected")
      expect(record.connected).to be(true)
    end

    it "broadcasts a replace to the system_status channel" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "system_status",
        target: "control_master_indicator",
        html: anything
      )
    end
  end

  context "when the connection fails" do
    before { allow(ControlMasterService).to receive(:start).and_return(false) }

    it "saves status 'disconnected' to SystemStatus" do
      described_class.perform_now
      record = SystemStatus.find_by(name: "control_master")
      expect(record.status).to eq("disconnected")
      expect(record.connected).to be(false)
    end
  end

  it "updates an existing record rather than creating a duplicate" do
    SystemStatus.create!(name: "control_master", connected: false, status: "connecting")
    allow(ControlMasterService).to receive(:start).and_return(true)

    expect { described_class.perform_now }.not_to change(SystemStatus, :count)
  end
end
