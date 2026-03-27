require "rails_helper"

RSpec.describe Dashboard::StatCardComponent, type: :component do
  subject(:component) do
    described_class.new(
      label: "Bugs Healed",
      value: "1,284",
      delta: "+12%",
      delta_direction: :up,
      sparkline_data: [ 42, 55, 48, 70, 65, 80 ]
    )
  end

  it "renders the label" do
    render_inline(component)
    expect(page).to have_text("Bugs Healed")
  end

  it "renders the value" do
    render_inline(component)
    expect(page).to have_text("1,284")
  end

  it "renders the delta" do
    render_inline(component)
    expect(page).to have_text("+12%")
  end

  it "renders the sparkline SVG when data is provided" do
    render_inline(component)
    expect(page).to have_css("svg.dispatch-sparkline")
    expect(page).to have_css("polyline.sparkline-path")
  end

  it "renders the trend icon for upward direction" do
    render_inline(component)
    expect(page).to have_text("↗")
  end

  context "when delta_direction is :down" do
    subject(:component) do
      described_class.new(
        label: "PRs",
        value: "10",
        delta: "-3%",
        delta_direction: :down,
        sparkline_data: [ 10, 8, 9, 7 ]
      )
    end

    it "applies danger color class" do
      render_inline(component)
      expect(page).to have_css(".dispatch-delta--down")
    end

    it "renders the downward trend icon" do
      render_inline(component)
      expect(page).to have_text("↘")
    end

    it "uses danger color in the sparkline stroke" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-danger)")
    end
  end

  context "when sparkline_data is empty" do
    subject(:component) do
      described_class.new(label: "X", value: "0", delta: "0%", delta_direction: :up)
    end

    it "does not render a sparkline" do
      render_inline(component)
      expect(page).not_to have_css("svg.dispatch-sparkline")
    end
  end

  describe "#sparkline_points" do
    it "returns a space-separated list of x,y coordinate pairs" do
      points = component.sparkline_points
      pairs = points.split(" ")
      expect(pairs.length).to eq(6)
      pairs.each { |p| expect(p).to match(/\A\d+\.?\d*,\d+\.?\d*\z/) }
    end
  end
end
