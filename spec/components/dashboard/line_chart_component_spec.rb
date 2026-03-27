require "rails_helper"

RSpec.describe Dashboard::LineChartComponent, type: :component do
  let(:data) do
    [
      DashboardPresenter::ChartPoint.new(label: "Jan", value: 50),
      DashboardPresenter::ChartPoint.new(label: "Feb", value: 75),
      DashboardPresenter::ChartPoint.new(label: "Mar", value: 60)
    ]
  end

  subject(:component) { described_class.new(data: data) }

  it "renders an SVG element" do
    render_inline(component)
    expect(page).to have_css("svg")
  end

  it "renders the stroke path" do
    render_inline(component)
    expect(page).to have_css("path.dispatch-line-chart__stroke")
  end

  it "renders the gradient fill path" do
    render_inline(component)
    expect(page).to have_css("path.dispatch-line-chart__fill")
  end

  it "includes a linearGradient definition" do
    render_inline(component)
    expect(rendered_content).to include("linearGradient")
  end

  it "renders x-axis labels for each data point" do
    render_inline(component)
    expect(page).to have_css("text", text: "Jan")
    expect(page).to have_css("text", text: "Feb")
    expect(page).to have_css("text", text: "Mar")
  end

  it "uses a unique gradient ID per instance" do
    component2 = described_class.new(data: data)
    expect(component.gradient_id).not_to eq(component2.gradient_id)
  end

  describe "#path_points" do
    it "returns one coordinate pair per data point" do
      expect(component.path_points.length).to eq(3)
    end

    it "returns [x, y] pairs" do
      component.path_points.each do |pt|
        expect(pt.length).to eq(2)
        expect(pt[0]).to be_a(Numeric)
        expect(pt[1]).to be_a(Numeric)
      end
    end
  end
end
