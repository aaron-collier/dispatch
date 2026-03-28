require "rails_helper"

RSpec.describe RefreshHoneybadgerJob, type: :job do
  let(:service) { instance_double(HoneybadgerService) }
  let(:repo)    { create(:repository, project_id: "proj_abc") }

  let(:deploy_data) do
    [
      { "id" => "dep_1", "environment" => "production", "revision" => "abc123",
        "local_username" => "amcollie", "created_at" => "2026-03-27T10:00:00Z" }
    ]
  end

  let(:fault_data) do
    [
      { "id" => "hb_1", "message" => "RuntimeError: boom", "environment" => "production",
        "last_notice_at" => "2026-03-27T10:00:00Z", "resolved" => false }
    ]
  end

  before do
    repo
    allow(HoneybadgerService).to receive(:new).and_return(service)
    allow(service).to receive(:deployments_for_repo).and_return(deploy_data)
    allow(service).to receive(:faults_for_repo).and_return(fault_data)
  end

  describe "#perform" do
    it "creates Deployment records from the API response" do
      expect { described_class.perform_now }.to change(Deployment, :count).by(1)
    end

    it "creates Fault records from the API response" do
      expect { described_class.perform_now }.to change(Fault, :count).by(1)
    end

    it "maps 'production' environment to :prod" do
      described_class.perform_now
      expect(Deployment.last.prod?).to be(true)
    end

    it "skips deployments that already exist (same revision + environment)" do
      create(:deployment, repository: repo, revision: "abc123", environment: :prod)
      expect { described_class.perform_now }.not_to change(Deployment, :count)
    end

    it "skips faults that are already in the database and unresolved" do
      create(:fault, repository: repo, honeybadger_id: "hb_1", environment: :prod, revision: "abc123")
      expect { described_class.perform_now }.not_to change(Fault, :count)
    end

    it "destroys faults that are now resolved" do
      existing = create(:fault, repository: repo, honeybadger_id: "hb_1", environment: :prod, revision: "abc123")
      resolved_data = [ fault_data.first.merge("resolved" => true) ]
      allow(service).to receive(:faults_for_repo).and_return(resolved_data)

      expect { described_class.perform_now }.to change(Fault, :count).by(-1)
      expect { existing.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when environment is 'staging'" do
      let(:deploy_data) do
        [ { "id" => "dep_2", "environment" => "staging", "revision" => "def456",
            "local_username" => "amcollie", "created_at" => "2026-03-27T10:00:00Z" } ]
      end

      it "maps 'staging' to :stage" do
        described_class.perform_now
        expect(Deployment.last.stage?).to be(true)
      end
    end
  end
end
