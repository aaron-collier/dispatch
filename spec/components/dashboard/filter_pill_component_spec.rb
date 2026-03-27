require "rails_helper"

RSpec.describe Dashboard::FilterPillComponent, type: :component do
  subject(:component) { described_class.new(options: %w[Last\ Month Last\ Week Last\ Year]) }

  it "renders the selected option (defaults to first)" do
    render_inline(component)
    expect(page).to have_text("Last Month")
  end

  it "renders all options in the dropdown" do
    render_inline(component)
    expect(page).to have_text("Last Week")
    expect(page).to have_text("Last Year")
  end

  it "renders a dropdown toggle button" do
    render_inline(component)
    expect(page).to have_css("button.dispatch-filter-pill")
  end

  context "when a selected option is provided" do
    subject(:component) { described_class.new(options: %w[Month Week], selected: "Week") }

    it "shows the provided selected value" do
      render_inline(component)
      expect(page).to have_css("button.dispatch-filter-pill", text: /Week/)
    end
  end
end
