require "rails_helper"

RSpec.describe Dashboard::DoraCardComponent, type: :component do
  subject(:component) do
    described_class.new(
      label: "Deployment Frequency",
      value: "4.2",
      unit: "/ day",
      tier: :elite,
      icon: "bi-rocket-takeoff"
    )
  end

  it "renders the label" do
    render_inline(component)
    expect(page).to have_text("Deployment Frequency")
  end

  it "renders the value" do
    render_inline(component)
    expect(page).to have_text("4.2")
  end

  it "renders the unit" do
    render_inline(component)
    expect(page).to have_text("/ day")
  end

  it "renders the tier badge label" do
    render_inline(component)
    expect(page).to have_text("Elite")
  end

  it "renders the tier bar with the elite modifier class" do
    render_inline(component)
    expect(page).to have_css(".dispatch-dora-tier__bar--elite")
  end

  it "renders the icon" do
    render_inline(component)
    expect(page).to have_css(".bi-rocket-takeoff")
  end

  context "with a high tier" do
    subject(:component) do
      described_class.new(label: "Change Failure Rate", value: "1.4", unit: "%", tier: :high, icon: "bi-shield-exclamation")
    end

    it "renders the high tier bar" do
      render_inline(component)
      expect(page).to have_css(".dispatch-dora-tier__bar--high")
    end

    it "renders High as the tier label" do
      render_inline(component)
      expect(page).to have_text("High")
    end
  end
end
