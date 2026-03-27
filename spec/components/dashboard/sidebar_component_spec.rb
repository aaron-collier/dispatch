require "rails_helper"

RSpec.describe Dashboard::SidebarComponent, type: :component do
  subject(:component) { described_class.new }

  it "renders the sidebar element" do
    render_inline(component)
    expect(page).to have_css("aside.dispatch-sidebar")
  end

  it "renders the logo wordmark" do
    render_inline(component)
    expect(page).to have_text("DISPATCH")
  end

  it "renders the search input" do
    render_inline(component)
    expect(page).to have_css("input[type='search']")
  end

  it "renders the nav sections" do
    render_inline(component)
    expect(page).to have_css("nav")
    expect(page).to have_text("Overview")
    expect(page).to have_text("Testing")
  end

  it "renders nav items" do
    render_inline(component)
    expect(page).to have_text("Dashboard")
    expect(page).to have_text("Deployments")
    expect(page).to have_text("Test Suites")
  end

  it "marks Dashboard as the active nav item" do
    render_inline(component)
    expect(page).to have_css("a.dispatch-sidebar__nav-link.active", text: /Dashboard/)
  end

  it "renders the theme toggle" do
    render_inline(component)
    expect(page).to have_css("input[type='checkbox'][data-theme-toggle]")
  end

  it "renders the user profile section" do
    render_inline(component)
    expect(page).to have_css(".dispatch-sidebar__user")
    expect(page).to have_text("Aaron Collier")
  end
end
