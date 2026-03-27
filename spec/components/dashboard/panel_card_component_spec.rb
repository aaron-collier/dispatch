require "rails_helper"

RSpec.describe Dashboard::PanelCardComponent, type: :component do
  it "renders the title as an all-caps dispatch label" do
    render_inline(described_class.new(title: "Stability Overview")) do |c|
      c.with_body { "content" }
    end
    expect(page).to have_text("Stability Overview")
    expect(page).to have_css(".dispatch-label")
  end

  it "renders the body slot content" do
    render_inline(described_class.new(title: "Test")) do |c|
      c.with_body { "<p class='inner'>hello</p>".html_safe }
    end
    expect(page).to have_css("p.inner", text: "hello")
  end

  it "does not render a filter pill when no options are given" do
    render_inline(described_class.new(title: "Test")) do |c|
      c.with_body { "content" }
    end
    expect(page).not_to have_css(".dispatch-filter-pill")
  end

  context "when filter_options are provided" do
    it "renders a filter pill" do
      render_inline(described_class.new(title: "Test", filter_options: %w[Month Week])) do |c|
        c.with_body { "content" }
      end
      expect(page).to have_css(".dispatch-filter-pill")
      expect(page).to have_text("Month")
    end
  end
end
