require "rails_helper"

RSpec.describe StopControlMasterJob, type: :job do
  before do
    allow(ControlMasterService).to receive(:stop)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  it "calls ControlMasterService.stop" do
    described_class.perform_now
    expect(ControlMasterService).to have_received(:stop)
  end

  it "saves status 'disconnected' to SystemStatus" do
    described_class.perform_now
    record = SystemStatus.find_by(name: "control_master")
    expect(record.status).to eq("disconnected")
    expect(record.connected).to be(false)
  end

  it "broadcasts a replace to the system_status channel" do
    described_class.perform_now
    expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
      "system_status",
      target: "control_master_indicator",
      html: anything
    )
  end

  it "updates an existing record rather than creating a duplicate" do
    SystemStatus.create!(name: "control_master", connected: true, status: "disconnecting")

    expect { described_class.perform_now }.not_to change(SystemStatus, :count)
    expect(SystemStatus.find_by(name: "control_master").status).to eq("disconnected")
  end
end
