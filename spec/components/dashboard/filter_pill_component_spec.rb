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

  context "in link mode (link_param and base_path provided)" do
    let(:options) do
      [
        { label: "Last Month", value: "last_month" },
        { label: "Last Week",  value: "last_week" }
      ]
    end

    subject(:component) do
      described_class.new(
        options:    options,
        selected:   "Last Month",
        link_param: "period",
        base_path:  "/deployments"
      )
    end

    it "renders anchor tags instead of buttons for options" do
      render_inline(component)
      expect(page).to have_css("a", text: "Last Month")
      expect(page).to have_css("a", text: "Last Week")
    end

    it "generates hrefs with the query param" do
      render_inline(component)
      expect(page).to have_css("a[href*='period=last_week']")
    end

    context "with extra_params" do
      subject(:component) do
        described_class.new(
          options:      options,
          selected:     "Last Month",
          link_param:   "period",
          base_path:    "/deployments",
          extra_params: { "env" => "prod" }
        )
      end

      it "includes extra params in every href" do
        render_inline(component)
        expect(page).to have_css("a[href*='env=prod']")
      end
    end

    it "still renders the dropdown toggle button" do
      render_inline(component)
      expect(page).to have_css("button.dispatch-filter-pill")
    end
  end
end
