require "rails_helper"

RSpec.describe Dashboard::HealthScoreComponent, type: :component do
  let(:segments) do
    [
      { label: "Passing", value: 847, color: "var(--dispatch-success)" },
      { label: "Flaky",   value: 43,  color: "var(--dispatch-warning)" },
      { label: "Failing", value: 12,  color: "var(--dispatch-danger)"  },
      { label: "Skipped", value: 22,  color: "var(--dispatch-text-muted)" }
    ]
  end

  subject(:component) { described_class.new(score: 94, label: "Excellent", segments: segments) }

  it "renders the score" do
    render_inline(component)
    expect(page).to have_text("94")
  end

  it "renders the label" do
    render_inline(component)
    expect(page).to have_text("Excellent")
  end

  it "renders the health bar" do
    render_inline(component)
    expect(page).to have_css(".dispatch-health-bar")
  end

  it "renders a segment for each entry" do
    render_inline(component)
    expect(page).to have_css(".dispatch-health-bar__segment", count: 4)
  end

  it "renders all segment labels in the legend" do
    render_inline(component)
    %w[Passing Flaky Failing Skipped].each do |label|
      expect(page).to have_text(label)
    end
  end

  describe "#total" do
    it "sums all segment values" do
      expect(component.total).to eq(924)
    end
  end
end
