require "rails_helper"

RSpec.describe Dashboard::SystemIndicatorComponent, type: :component do
  context "when connected (boolean only, e.g. VPN)" do
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

  context "when disconnected (boolean only)" do
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

  context "with status: 'connecting'" do
    subject(:component) do
      described_class.new(key: "control_master", label: "Control Master", connected: false, status: "connecting")
    end

    it "displays 'Connecting...'" do
      render_inline(component)
      expect(page).to have_text("Connecting...")
    end

    it "uses the warning color" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-warning)")
    end

    it "renders plain text, not a link" do
      render_inline(component)
      expect(page).not_to have_css("a")
    end
  end

  context "with status: 'disconnecting'" do
    subject(:component) do
      described_class.new(key: "control_master", label: "Control Master", connected: true, status: "disconnecting")
    end

    it "displays 'Disconnecting...'" do
      render_inline(component)
      expect(page).to have_text("Disconnecting...")
    end

    it "uses the warning color" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-warning)")
    end
  end

  context "with status: 'disconnected' and a connect_path" do
    subject(:component) do
      described_class.new(
        key: "control_master",
        label: "Control Master",
        connected: false,
        status: "disconnected",
        connect_path: "/control_master/connect",
        disconnect_path: "/control_master/disconnect"
      )
    end

    it "renders 'Disconnected' as a link to connect" do
      render_inline(component)
      expect(page).to have_link("Disconnected", href: "/control_master/connect")
    end

    it "includes the connect tooltip" do
      render_inline(component)
      expect(rendered_content).to include("Click to connect control master")
    end

    it "does not render a disconnect link" do
      render_inline(component)
      expect(rendered_content).not_to include("/control_master/disconnect")
    end
  end

  context "with status: 'connected' and a disconnect_path" do
    subject(:component) do
      described_class.new(
        key: "control_master",
        label: "Control Master",
        connected: true,
        status: "connected",
        connect_path: "/control_master/connect",
        disconnect_path: "/control_master/disconnect"
      )
    end

    it "renders 'Connected' as a link to disconnect" do
      render_inline(component)
      expect(page).to have_link("Connected", href: "/control_master/disconnect")
    end

    it "includes the disconnect tooltip" do
      render_inline(component)
      expect(rendered_content).to include("Click to disconnect control master")
    end
  end
end
