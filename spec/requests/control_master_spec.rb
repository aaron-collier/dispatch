require "rails_helper"

RSpec.describe "ControlMaster", type: :request do
  before do
    allow(StartControlMasterJob).to receive(:perform_later)
    allow(StopControlMasterJob).to receive(:perform_later)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  describe "POST /control_master/connect" do
    it "sets the control master status to 'connecting'" do
      post connect_control_master_path
      expect(SystemStatus.find_by(name: "control_master").status).to eq("connecting")
    end

    it "enqueues StartControlMasterJob" do
      post connect_control_master_path
      expect(StartControlMasterJob).to have_received(:perform_later)
    end

    it "responds with a turbo stream" do
      post connect_control_master_path
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end

    context "when a record already exists" do
      before { SystemStatus.create!(name: "control_master", connected: true, status: "connected") }

      it "updates rather than duplicates the record" do
        expect { post connect_control_master_path }.not_to change(SystemStatus, :count)
        expect(SystemStatus.find_by(name: "control_master").status).to eq("connecting")
      end
    end
  end

  describe "POST /control_master/disconnect" do
    before { SystemStatus.create!(name: "control_master", connected: true, status: "connected") }

    it "sets the control master status to 'disconnecting'" do
      post disconnect_control_master_path
      expect(SystemStatus.find_by(name: "control_master").status).to eq("disconnecting")
    end

    it "enqueues StopControlMasterJob" do
      post disconnect_control_master_path
      expect(StopControlMasterJob).to have_received(:perform_later)
    end

    it "responds with a turbo stream" do
      post disconnect_control_master_path
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end
  end
end
