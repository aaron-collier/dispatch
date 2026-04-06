require "rails_helper"

RSpec.describe FetchDependencyUpdatesJob, type: :job do
  let(:repo)   { create(:repository, name: "sul-dlss/argo") }
  let(:client) { instance_double(Octokit::Client) }

  let(:open_pr) do
    double("PR",
      number: 42,
      head: double(ref: "update-dependencies", sha: "abc123"))
  end

  let(:check_runs_response) do
    { check_runs: [ double("run", status: "completed", conclusion: "success") ] }
  end

  before do
    repo
    allow(Octokit::Client).to receive(:new).and_return(client)
    allow(client).to receive(:pull_requests).and_return([ open_pr ])
    allow(client).to receive(:pull_request).and_return(open_pr)
    allow(client).to receive(:check_runs_for_ref).and_return(check_runs_response)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
    allow(Settings).to receive(:update_branch).and_return("update-dependencies")
    allow(Settings).to receive(:github_auth_token).and_return(nil)
  end

  describe "#perform" do
    it "creates UpdatePullRequest records for matching open PRs" do
      expect { described_class.perform_now }.to change(UpdatePullRequest, :count).by(1)
    end

    it "sets status to open" do
      described_class.perform_now
      expect(UpdatePullRequest.last.status_open?).to be(true)
    end

    it "sets build to passing when all checks succeed" do
      described_class.perform_now
      expect(UpdatePullRequest.last.build_passing?).to be(true)
    end

    it "broadcasts a Turbo Stream replace for the card" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "dependency_updates",
        target: "dependency_update_card",
        html: anything
      )
    end

    it "broadcasts a Turbo Stream replace for the feed" do
      described_class.perform_now
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "dependency_updates",
        target: "dependency_update_feed",
        html: anything
      )
    end

    it "does not create a duplicate when the PR already exists" do
      create(:update_pull_request, repository: repo, pull_request: 42)
      expect { described_class.perform_now }.not_to change(UpdatePullRequest, :count)
    end

    context "when a PR has an in-progress check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "in_progress", conclusion: nil) ] }
      end

      it "sets build to building" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_building?).to be(true)
      end
    end

    context "when a PR has a failing check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "completed", conclusion: "failure") ] }
      end

      it "sets build to failing" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_failing?).to be(true)
      end
    end

    context "when a PR has a cancelled check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "completed", conclusion: "cancelled") ] }
      end

      it "sets build to failing" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_failing?).to be(true)
      end
    end

    context "when a PR has a timed out check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "completed", conclusion: "timed_out") ] }
      end

      it "sets build to failing" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_failing?).to be(true)
      end
    end

    context "when a PR has an action_required check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "completed", conclusion: "action_required") ] }
      end

      it "sets build to failing" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_failing?).to be(true)
      end
    end

    context "when a PR has a startup_failure check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "completed", conclusion: "startup_failure") ] }
      end

      it "sets build to failing" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_failing?).to be(true)
      end
    end

    context "when a PR has a queued check" do
      let(:check_runs_response) do
        { check_runs: [ double("run", status: "queued", conclusion: nil) ] }
      end

      it "sets build to building" do
        described_class.perform_now
        expect(UpdatePullRequest.last.build_building?).to be(true)
      end
    end

    context "when the PR branch does not match update_branch" do
      let(:open_pr) do
        double("PR", number: 99, head: double(ref: "some-other-branch", sha: "xyz"))
      end

      it "does not create a record" do
        expect { described_class.perform_now }.not_to change(UpdatePullRequest, :count)
      end
    end

    context "when a stale open PR is no longer in the open list" do
      it "marks it closed" do
        stale = create(:update_pull_request, repository: repo, pull_request: 99, status: :open)
        described_class.perform_now
        expect(stale.reload.status_closed?).to be(true)
      end
    end

    context "when the repository is not found on GitHub" do
      before do
        allow(client).to receive(:pull_requests).and_raise(Octokit::NotFound)
      end

      it "does not raise an error" do
        expect { described_class.perform_now }.not_to raise_error
      end
    end

    context "when github_auth_token is set in Settings" do
      before { allow(Settings).to receive(:github_auth_token).and_return("settings_token") }

      it "passes the token to Octokit" do
        described_class.perform_now
        expect(Octokit::Client).to have_received(:new).with(access_token: "settings_token")
      end
    end

    context "when GH_ACCESS_TOKEN env var is set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("GH_ACCESS_TOKEN").and_return("env_token")
      end

      it "passes the env token to Octokit" do
        described_class.perform_now
        expect(Octokit::Client).to have_received(:new).with(access_token: "env_token")
      end
    end

    context "when Settings token takes precedence over env var" do
      before do
        allow(Settings).to receive(:github_auth_token).and_return("settings_token")
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("GH_ACCESS_TOKEN").and_return("env_token")
      end

      it "uses the Settings token" do
        described_class.perform_now
        expect(Octokit::Client).to have_received(:new).with(access_token: "settings_token")
      end
    end
  end
end
