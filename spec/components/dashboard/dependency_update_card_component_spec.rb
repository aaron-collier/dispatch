require "rails_helper"

RSpec.describe Dashboard::DependencyUpdateCardComponent, type: :component do
  let(:merge_path)   { "/dependency_updates/merge_all" }
  let(:release_path) { "/dependency_updates/release_all" }

  subject(:component) do
    described_class.new(open_count: 17, passing: 12, building: 3, failing: 2,
                        all_merged: false, merge_all_path: merge_path, release_all_path: release_path)
  end

  it "renders with the correct turbo target id" do
    render_inline(component)
    expect(page).to have_css("#dependency_update_card")
  end

  it "renders the DEPENDENCY UPDATES label" do
    render_inline(component)
    expect(page).to have_text("DEPENDENCY UPDATES")
  end

  it "renders the open PR count" do
    render_inline(component)
    expect(page).to have_text("17")
  end

  it "renders the passing count in green" do
    render_inline(component)
    expect(rendered_content).to include("var(--dispatch-success)")
    expect(page).to have_text("12 passing")
  end

  it "renders the running count in yellow" do
    render_inline(component)
    expect(rendered_content).to include("var(--dispatch-warning)")
    expect(page).to have_text("3 running")
  end

  it "renders the failing count in red" do
    render_inline(component)
    expect(rendered_content).to include("var(--dispatch-danger)")
    expect(page).to have_text("2 failing")
  end

  context "when there are no open PRs" do
    subject(:component) do
      described_class.new(open_count: 0, passing: 0, building: 0, failing: 0,
                          all_merged: false, merge_all_path: merge_path, release_all_path: release_path)
    end

    it "renders 0 as the count" do
      render_inline(component)
      expect(page).to have_text("0")
    end
  end

  describe "MERGE ALL button" do
    context "when all open PRs are passing" do
      subject(:component) do
        described_class.new(open_count: 5, passing: 5, building: 0, failing: 0,
                            all_merged: false, merge_all_path: merge_path, release_all_path: release_path)
      end

      it "renders the MERGE ALL button" do
        render_inline(component)
        expect(page).to have_link("MERGE ALL", href: merge_path)
      end

      it "does not render the RELEASE button" do
        render_inline(component)
        expect(page).not_to have_link("RELEASE")
      end
    end

    context "when some PRs are still building" do
      subject(:component) do
        described_class.new(open_count: 5, passing: 3, building: 2, failing: 0,
                            all_merged: false, merge_all_path: merge_path, release_all_path: release_path)
      end

      it "does not render the MERGE ALL button" do
        render_inline(component)
        expect(page).not_to have_link("MERGE ALL")
      end
    end

    context "when merge_all_path is nil" do
      subject(:component) do
        described_class.new(open_count: 5, passing: 5, building: 0, failing: 0,
                            all_merged: false, merge_all_path: nil, release_all_path: nil)
      end

      it "does not render the MERGE ALL button" do
        render_inline(component)
        expect(page).not_to have_link("MERGE ALL")
      end
    end
  end

  describe "RELEASE button" do
    context "when all PRs have been merged" do
      subject(:component) do
        described_class.new(open_count: 0, passing: 0, building: 0, failing: 0,
                            all_merged: true, merge_all_path: merge_path, release_all_path: release_path)
      end

      it "renders the RELEASE button" do
        render_inline(component)
        expect(page).to have_link("RELEASE", href: release_path)
      end

      it "does not render the MERGE ALL button" do
        render_inline(component)
        expect(page).not_to have_link("MERGE ALL")
      end
    end

    context "when release_all_path is nil" do
      subject(:component) do
        described_class.new(open_count: 0, passing: 0, building: 0, failing: 0,
                            all_merged: true, merge_all_path: nil, release_all_path: nil)
      end

      it "does not render the RELEASE button" do
        render_inline(component)
        expect(page).not_to have_link("RELEASE")
      end
    end
  end
end
