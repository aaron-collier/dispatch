require "rails_helper"

RSpec.describe MergePullRequestJob, type: :job do
  let(:repo)   { create(:repository, name: "sul-dlss/argo") }
  let(:pr)     { create(:update_pull_request, repository: repo, pull_request: 42) }
  let(:client) { instance_double(Octokit::Client) }

  before do
    pr
    allow(Octokit::Client).to receive(:new).and_return(client)
    allow(client).to receive(:merge_pull_request)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
    allow(Settings).to receive(:github_auth_token).and_return(nil)
    allow(Settings).to receive(:name).and_return("Test User")
  end

  describe "#perform" do
    it "merges the pull request via the GitHub API" do
      described_class.perform_now(repo.id, 42)
      expect(client).to have_received(:merge_pull_request).with("sul-dlss/argo", 42, anything)
    end

    it "marks the UpdatePullRequest as merged" do
      described_class.perform_now(repo.id, 42)
      expect(pr.reload.status_merged?).to be(true)
    end

    it "broadcasts an update to the dependency_update_card" do
      described_class.perform_now(repo.id, 42)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "dependency_updates",
        target: "dependency_update_card",
        html: anything
      )
    end

    it "broadcasts an update to the dependency_update_feed" do
      described_class.perform_now(repo.id, 42)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "dependency_updates",
        target: "dependency_update_feed",
        html: anything
      )
    end

    context "when the GitHub API rejects the merge" do
      before { allow(client).to receive(:merge_pull_request).and_raise(Octokit::MethodNotAllowed) }

      it "does not raise an error" do
        expect { described_class.perform_now(repo.id, 42) }.not_to raise_error
      end

      it "does not mark the PR as merged" do
        described_class.perform_now(repo.id, 42)
        expect(pr.reload.status_merged?).to be(false)
      end
    end

    context "when github_auth_token is set in Settings" do
      before { allow(Settings).to receive(:github_auth_token).and_return("token123") }

      it "passes the token to Octokit" do
        described_class.perform_now(repo.id, 42)
        expect(Octokit::Client).to have_received(:new).with(access_token: "token123")
      end
    end
  end
end
