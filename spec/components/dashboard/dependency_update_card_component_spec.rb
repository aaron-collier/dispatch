require "rails_helper"

RSpec.describe Dashboard::DependencyUpdateCardComponent, type: :component do
  subject(:component) { described_class.new(open_count: 17, passing: 12, building: 3, failing: 2) }

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
    subject(:component) { described_class.new(open_count: 0, passing: 0, building: 0, failing: 0) }

    it "renders 0 as the count" do
      render_inline(component)
      expect(page).to have_text("0")
    end
  end
end
