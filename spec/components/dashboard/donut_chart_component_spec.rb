require "rails_helper"

RSpec.describe Dashboard::DonutChartComponent, type: :component do
  let(:slices) do
    [
      DashboardPresenter::DonutSlice.new(label: "Passing", value: 847, color: "var(--dispatch-success)"),
      DashboardPresenter::DonutSlice.new(label: "Flaky",   value: 43,  color: "var(--dispatch-warning)"),
      DashboardPresenter::DonutSlice.new(label: "Failing", value: 12,  color: "var(--dispatch-danger)")
    ]
  end

  subject(:component) { described_class.new(slices: slices) }

  it "renders an SVG element" do
    render_inline(component)
    expect(page).to have_css("svg")
  end

  it "renders a circle for each slice" do
    render_inline(component)
    # 1 background + n segments
    expect(page).to have_css("circle", minimum: slices.length)
  end

  it "renders the total in the center label" do
    render_inline(component)
    expect(page).to have_css("text", text: "902")
  end

  it "renders legend entries for each slice" do
    render_inline(component)
    expect(page).to have_css(".dispatch-donut-legend__item", count: 3)
    expect(page).to have_text("Passing")
    expect(page).to have_text("Flaky")
    expect(page).to have_text("Failing")
  end

  it "renders colored dots for each legend entry" do
    render_inline(component)
    expect(page).to have_css(".dispatch-donut-legend__dot", count: 3)
  end

  describe "#total" do
    it "sums all slice values" do
      expect(component.total).to eq(902.0)
    end
  end

  describe "#segments" do
    it "returns one segment per slice" do
      expect(component.segments.length).to eq(3)
    end

    it "assigns dasharray and dashoffset to each segment" do
      component.segments.each do |seg|
        expect(seg[:dasharray]).to be_present
        expect(seg[:dashoffset]).to be_a(Numeric)
      end
    end
  end
end
