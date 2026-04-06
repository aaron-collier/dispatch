require "rails_helper"

RSpec.describe DependencyUpdatesFeedPresenter do
  let(:repo_a) { create(:repository, name: "sul-dlss/argo") }
  let(:repo_b) { create(:repository, name: "sul-dlss/sul-pub") }

  subject(:presenter) { described_class.new }

  describe "#rows" do
    it "returns one row per repository" do
      repo_a
      repo_b
      expect(presenter.rows.length).to eq(2)
    end

    it "orders repositories alphabetically by name" do
      repo_a
      repo_b
      names = presenter.rows.map(&:repo_name)
      expect(names).to eq(names.sort)
    end

    context "when a repository has an open passing PR" do
      before { create(:update_pull_request, repository: repo_a, pull_request: 42, build: :passing) }

      it "sets pr_state to :passing" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_state).to eq(:passing)
      end

      it "includes the PR URL" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_url).to eq("https://github.com/sul-dlss/argo/pull/42")
      end
    end

    context "when a repository has an open building PR" do
      before { create(:update_pull_request, :building, repository: repo_a) }

      it "sets pr_state to :building" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_state).to eq(:building)
      end
    end

    context "when a repository has an open failing PR" do
      before { create(:update_pull_request, :failing, repository: repo_a) }

      it "sets pr_state to :failing" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_state).to eq(:failing)
      end
    end

    context "when a repository has no open PR but a recently closed one" do
      before do
        create(:update_pull_request, :closed, repository: repo_a, pull_request: 99,
               updated_at: 3.days.ago)
      end

      it "sets pr_state to :merged" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_state).to eq(:merged)
      end

      it "includes the PR URL" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_url).to eq("https://github.com/sul-dlss/argo/pull/99")
      end
    end

    context "when a repository has a closed PR older than a week" do
      before do
        create(:update_pull_request, :closed, repository: repo_a,
               updated_at: 2.weeks.ago)
      end

      it "sets pr_state to :none" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_state).to eq(:none)
      end

      it "sets pr_url to nil" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_url).to be_nil
      end
    end

    context "when a repository has no PRs at all" do
      before { repo_a }

      it "sets pr_state to :none" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_state).to eq(:none)
      end

      it "sets pr_url to nil" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.pr_url).to be_nil
      end
    end

    context "when a repository has a release tag" do
      before { repo_a.update!(release_tag: "rel-2026-04-06") }

      it "includes the release tag in the row" do
        create(:update_pull_request, repository: repo_a)
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.release_tag).to eq("rel-2026-04-06")
      end
    end

    context "when a repository has no release tag" do
      before { repo_a }

      it "sets release_tag to nil" do
        row = presenter.rows.find { |r| r.repo_name == repo_a.name }
        expect(row.release_tag).to be_nil
      end
    end
  end
end
