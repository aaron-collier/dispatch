require "rails_helper"

RSpec.describe CreateReleaseJob, type: :job do
  let(:repo)   { create(:repository, name: "sul-dlss/argo") }
  let(:client) { instance_double(Octokit::Client) }

  before do
    repo
    allow(Octokit::Client).to receive(:new).and_return(client)
    allow(client).to receive(:create_release)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
    allow(Settings).to receive(:github_auth_token).and_return(nil)
    allow(Settings).to receive(:name).and_return("Aaron Collier")
  end

  describe "#perform" do
    it "creates a GitHub release with the correct tag" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 4, 6))
      described_class.perform_now(repo.id)
      expect(client).to have_received(:create_release).with(
        "sul-dlss/argo",
        "rel-2026-04-06",
        hash_including(name: "rel-2026-04-06")
      )
    end

    it "includes the Settings.name in the release message" do
      described_class.perform_now(repo.id)
      expect(client).to have_received(:create_release).with(
        anything,
        anything,
        hash_including(body: "created by Aaron Collier using dispatch")
      )
    end

    it "stores the release tag on the repository" do
      allow(Date).to receive(:current).and_return(Date.new(2026, 4, 6))
      described_class.perform_now(repo.id)
      expect(repo.reload.release_tag).to eq("rel-2026-04-06")
    end

    it "broadcasts an update to the dependency_update_card" do
      described_class.perform_now(repo.id)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "dependency_updates",
        target: "dependency_update_card",
        html: anything
      )
    end

    it "broadcasts an update to the dependency_update_feed" do
      described_class.perform_now(repo.id)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "dependency_updates",
        target: "dependency_update_feed",
        html: anything
      )
    end

    context "when the GitHub API returns an error" do
      before { allow(client).to receive(:create_release).and_raise(Octokit::UnprocessableEntity) }

      it "does not raise an error" do
        expect { described_class.perform_now(repo.id) }.not_to raise_error
      end

      it "does not set the release tag" do
        described_class.perform_now(repo.id)
        expect(repo.reload.release_tag).to be_nil
      end
    end

    context "when github_auth_token is set in Settings" do
      before { allow(Settings).to receive(:github_auth_token).and_return("tok") }

      it "passes the token to Octokit" do
        described_class.perform_now(repo.id)
        expect(Octokit::Client).to have_received(:new).with(access_token: "tok")
      end
    end
  end
end
