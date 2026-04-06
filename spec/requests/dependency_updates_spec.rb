require "rails_helper"

RSpec.describe "DependencyUpdates", type: :request do
  before do
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  describe "POST /dependency_updates/merge_all" do
    let(:repo) { create(:repository) }

    before do
      create(:update_pull_request, repository: repo, build: :passing)
      allow(MergePullRequestJob).to receive(:perform_later)
    end

    it "enqueues a MergePullRequestJob for each open passing PR" do
      post merge_all_dependency_updates_path
      expect(MergePullRequestJob).to have_received(:perform_later).once
    end

    it "responds with a turbo stream" do
      post merge_all_dependency_updates_path
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end

    it "does not enqueue jobs for building PRs" do
      create(:update_pull_request, :building, repository: repo, pull_request: 99)
      post merge_all_dependency_updates_path
      expect(MergePullRequestJob).to have_received(:perform_later).once
    end

    it "does not enqueue jobs for failing PRs" do
      create(:update_pull_request, :failing, repository: repo, pull_request: 100)
      post merge_all_dependency_updates_path
      expect(MergePullRequestJob).to have_received(:perform_later).once
    end
  end

  describe "POST /dependency_updates/release_all" do
    let(:repo) { create(:repository) }

    before do
      create(:update_pull_request, :merged, repository: repo, updated_at: 1.hour.ago)
      allow(CreateReleaseJob).to receive(:perform_later)
    end

    it "enqueues a CreateReleaseJob for each repo with recently merged PRs" do
      post release_all_dependency_updates_path
      expect(CreateReleaseJob).to have_received(:perform_later).with(repo.id)
    end

    it "responds with a turbo stream" do
      post release_all_dependency_updates_path
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end

    it "does not enqueue jobs for repos whose merged PRs are older than a day" do
      old_repo = create(:repository, name: "sul-dlss/old-repo")
      create(:update_pull_request, :merged, repository: old_repo, pull_request: 200,
             updated_at: 2.days.ago)
      post release_all_dependency_updates_path
      expect(CreateReleaseJob).not_to have_received(:perform_later).with(old_repo.id)
    end

    it "does not enqueue jobs for repos that already have a release tag" do
      repo.update!(release_tag: "rel-2026-04-06")
      post release_all_dependency_updates_path
      expect(CreateReleaseJob).not_to have_received(:perform_later)
    end
  end
end
