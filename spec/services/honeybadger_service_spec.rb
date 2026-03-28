require "rails_helper"

RSpec.describe HoneybadgerService do
  subject(:service) { described_class.new }

  let(:faults_payload) do
    {
      "results" => [
        { "id" => "hb_1", "message" => "RuntimeError: boom", "environment" => "production",
          "last_notice_at" => "2026-03-27T10:00:00Z", "resolved" => false },
        { "id" => "hb_2", "message" => "NoMethodError: undefined", "environment" => "production",
          "last_notice_at" => "2026-03-26T10:00:00Z", "resolved" => false }
      ]
    }
  end

  let(:deploys_payload) do
    {
      "results" => [
        { "id" => "dep_1", "environment" => "production", "revision" => "abc123",
          "local_username" => "amcollie", "created_at" => "2026-03-27T10:00:00Z" }
      ]
    }
  end

  let(:projects_payload) do
    { "results" => [ { "id" => "proj_abc", "name" => "argo" } ] }
  end

  describe "#faults_for_repo" do
    let(:repo) { build(:repository, project_id: "proj_abc") }

    before { allow(service).to receive(:get).with("projects/proj_abc/faults", anything).and_return(faults_payload) }

    it "returns the results array from the API response" do
      expect(service.faults_for_repo(repo)).to eq(faults_payload["results"])
    end

    it "limits results to Settings.honeybadger_api.max_faults" do
      large_payload = { "results" => Array.new(20) { |i| { "id" => "hb_#{i}" } } }
      allow(service).to receive(:get).and_return(large_payload)
      expect(service.faults_for_repo(repo).length).to be <= Settings.honeybadger_api.max_faults
    end

    it "returns [] when project_id is nil" do
      repo_without_id = build(:repository, project_id: nil)
      allow(service).to receive(:get).with("projects").and_return({ "results" => [] })
      expect(service.faults_for_repo(repo_without_id)).to eq([])
    end
  end

  describe "#deployments_for_repo" do
    let(:repo) { build(:repository, project_id: "proj_abc") }

    before { allow(service).to receive(:get).with("projects/proj_abc/deploys", anything).and_return(deploys_payload) }

    it "returns the results array from the API response" do
      expect(service.deployments_for_repo(repo)).to eq(deploys_payload["results"])
    end

    it "limits results to Settings.honeybadger_api.max_deploys" do
      large_payload = { "results" => Array.new(20) { |i| { "id" => "dep_#{i}" } } }
      allow(service).to receive(:get).and_return(large_payload)
      expect(service.deployments_for_repo(repo).length).to be <= Settings.honeybadger_api.max_deploys
    end
  end

  describe "project_id resolution" do
    context "when the repository already has a project_id" do
      let(:repo) { build(:repository, project_id: "proj_abc") }

      it "does not call the /projects endpoint" do
        allow(service).to receive(:get).with("projects/proj_abc/faults", anything).and_return(faults_payload)
        service.faults_for_repo(repo)
        expect(service).not_to have_received(:get).with("projects")
      end
    end

    context "when the repository has no project_id" do
      let(:repo) { create(:repository, name: "sul-dlss/argo", project_id: nil) }

      before do
        allow(service).to receive(:get).with("projects").and_return(projects_payload)
        allow(service).to receive(:get).with("projects/proj_abc/faults", anything).and_return(faults_payload)
      end

      it "looks up the project_id from the /projects API" do
        service.faults_for_repo(repo)
        expect(repo.reload.project_id).to eq("proj_abc")
      end

      it "uses the discovered project_id to fetch faults" do
        expect(service.faults_for_repo(repo)).to eq(faults_payload["results"])
      end
    end
  end

  describe "#get (integration)" do
    it "uses Basic auth with HONEYBADGER_AUTH_TOKEN" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("HONEYBADGER_AUTH_TOKEN").and_return("secret_token")

      captured_request = nil
      allow_any_instance_of(Net::HTTP).to receive(:request) do |_, req|
        captured_request = req
        instance_double(Net::HTTPSuccess, is_a?: true, body: '{"results":[]}').tap do |r|
          allow(r).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        end
      end

      service.send(:get, "projects")
      expect(captured_request["Authorization"]).to start_with("Basic ")
    end
  end
end
