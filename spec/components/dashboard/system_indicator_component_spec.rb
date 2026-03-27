require "rails_helper"

RSpec.describe Dashboard::SystemIndicatorComponent, type: :component do
  context "when connected" do
    subject(:component) { described_class.new(key: "vpn", label: "VPN", connected: true) }

    it "renders with the correct id" do
      render_inline(component)
      expect(page).to have_css("#vpn_indicator")
    end

    it "displays the label" do
      render_inline(component)
      expect(page).to have_text("VPN")
    end

    it "displays Connected status text" do
      render_inline(component)
      expect(page).to have_text("Connected")
    end

    it "uses the success color for dot and status" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-success)")
    end
  end

  context "when disconnected" do
    subject(:component) { described_class.new(key: "control_master", label: "Control Master", connected: false) }

    it "renders with the correct id" do
      render_inline(component)
      expect(page).to have_css("#control_master_indicator")
    end

    it "displays Disconnected status text" do
      render_inline(component)
      expect(page).to have_text("Disconnected")
    end

    it "uses the danger color for dot and status" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-danger)")
    end
  end
end
