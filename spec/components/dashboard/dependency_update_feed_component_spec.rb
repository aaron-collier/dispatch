require "rails_helper"

RSpec.describe Dashboard::DependencyUpdateFeedComponent, type: :component do
  let(:passing_row) do
    DependencyUpdatesFeedPresenter::DependencyUpdateRow.new(
      repo_name: "sul-dlss/argo",
      pr_url: "https://github.com/sul-dlss/argo/pull/42",
      pr_state: :passing,
      release_tag: nil
    )
  end

  let(:building_row) do
    DependencyUpdatesFeedPresenter::DependencyUpdateRow.new(
      repo_name: "sul-dlss/sul-pub",
      pr_url: "https://github.com/sul-dlss/sul-pub/pull/10",
      pr_state: :building,
      release_tag: nil
    )
  end

  let(:failing_row) do
    DependencyUpdatesFeedPresenter::DependencyUpdateRow.new(
      repo_name: "sul-dlss/dor-services",
      pr_url: "https://github.com/sul-dlss/dor-services/pull/5",
      pr_state: :failing,
      release_tag: nil
    )
  end

  let(:merged_row) do
    DependencyUpdatesFeedPresenter::DependencyUpdateRow.new(
      repo_name: "sul-dlss/cocina-models",
      pr_url: "https://github.com/sul-dlss/cocina-models/pull/3",
      pr_state: :merged,
      release_tag: nil
    )
  end

  let(:none_row) do
    DependencyUpdatesFeedPresenter::DependencyUpdateRow.new(
      repo_name: "sul-dlss/hydra-etd",
      pr_url: nil,
      pr_state: :none,
      release_tag: nil
    )
  end

  subject(:component) { described_class.new(rows: [ passing_row, building_row, failing_row, merged_row, none_row ]) }

  it "renders with the correct turbo target id" do
    render_inline(component)
    expect(page).to have_css("#dependency_update_feed")
  end

  it "renders a row for each repository" do
    render_inline(component)
    expect(page).to have_css(".dispatch-feed__item", count: 5)
  end

  it "renders the git icon for each row" do
    render_inline(component)
    expect(page).to have_css(".bi-git", count: 5)
  end

  it "renders 4 circle lights per row" do
    render_inline(component)
    expect(page).to have_css(".bi-circle-fill", count: 20)
  end

  it "displays the short repo name (without org prefix)" do
    render_inline(component)
    expect(page).to have_text("argo")
    expect(page).not_to have_text("sul-dlss/argo")
  end

  it "links the repo name to the PR URL" do
    render_inline(component)
    expect(page).to have_link("argo", href: "https://github.com/sul-dlss/argo/pull/42")
  end

  it "does not link the repo name when there is no PR URL" do
    render_inline(component)
    expect(page).to have_text("hydra-etd")
    expect(page).not_to have_link("hydra-etd")
  end

  describe "icon colors" do
    it "uses bright green for passing PR icon" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-dora-elite)")
    end

    it "uses bright yellow for building PR icon" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-dora-mid)")
    end

    it "uses bright red for failing PR icon" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-dora-low)")
    end

    it "uses light purple for merged PR icon" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-purple-light)")
    end
  end

  describe "light_colors_for" do
    subject(:component) { described_class.new(rows: []) }

    it "returns bright green as first light for passing" do
      expect(component.light_colors_for(:passing).first).to eq("var(--dispatch-dora-elite)")
    end

    it "returns bright yellow as second light for building" do
      expect(component.light_colors_for(:building)[1]).to eq("var(--dispatch-dora-mid)")
    end

    it "returns bright red as third light for failing" do
      expect(component.light_colors_for(:failing)[2]).to eq("var(--dispatch-dora-low)")
    end

    it "returns light purple as fourth light for merged" do
      expect(component.light_colors_for(:merged)[3]).to eq("var(--dispatch-purple-light)")
    end

    it "returns all grey for none state" do
      colors = component.light_colors_for(:none)
      expect(colors).to all(eq("var(--dispatch-text-muted)"))
    end
  end

  describe "release tag" do
    let(:released_row) do
      DependencyUpdatesFeedPresenter::DependencyUpdateRow.new(
        repo_name: "sul-dlss/argo",
        pr_url: "https://github.com/sul-dlss/argo/pull/42",
        pr_state: :merged,
        release_tag: "rel-2026-04-06"
      )
    end

    subject(:component) { described_class.new(rows: [ released_row ]) }

    it "renders the release tag next to the repo name" do
      render_inline(component)
      expect(page).to have_text("(rel-2026-04-06)")
    end
  end

  describe "short_name" do
    subject(:component) { described_class.new(rows: []) }

    it "strips the org prefix" do
      expect(component.short_name("sul-dlss/argo")).to eq("argo")
    end

    it "returns the name as-is when there is no slash" do
      expect(component.short_name("standalone")).to eq("standalone")
    end
  end
end
