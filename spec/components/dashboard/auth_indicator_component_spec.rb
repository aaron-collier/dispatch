require "rails_helper"

RSpec.describe Dashboard::AuthIndicatorComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "when authenticated" do
    subject(:component) { described_class.new(authenticated: true) }

    it "renders with the correct id" do
      render_inline(component)
      expect(page).to have_css("#auth_indicator")
    end

    it "displays the label" do
      render_inline(component)
      expect(page).to have_text("2FA Auth")
    end

    it "displays Authenticated status text" do
      render_inline(component)
      expect(page).to have_text("Authenticated")
    end

    it "uses the success color for dot and status" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-success)")
    end

    it "does not render a link to the auth page" do
      render_inline(component)
      expect(page).not_to have_link("Authenticated")
    end
  end

  context "when not authenticated" do
    subject(:component) { described_class.new(authenticated: false) }

    it "renders with the correct id" do
      render_inline(component)
      expect(page).to have_css("#auth_indicator")
    end

    it "displays Not Authenticated status text" do
      render_inline(component)
      expect(page).to have_text("Not Authenticated")
    end

    it "uses the danger color for dot and status" do
      render_inline(component)
      expect(rendered_content).to include("var(--dispatch-danger)")
    end

    it "renders a link to the auth page" do
      render_inline(component)
      expect(page).to have_link("Not Authenticated", href: new_auth_path)
    end
  end
end
