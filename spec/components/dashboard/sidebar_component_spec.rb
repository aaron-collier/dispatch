require "rails_helper"

RSpec.describe Dashboard::SidebarComponent, type: :component do
  let(:user) { instance_double(UserPresenter, name: "Test User", email: "testuser@stanford.edu", initials: "TU", avatar_url: nil, github_profile_url: nil, github_username: nil) }

  subject(:component) { described_class.new(user: user) }

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
    expect(page).to have_text("Test Suite")
  end

  it "marks Dashboard as the active nav item by default" do
    render_inline(component)
    expect(page).to have_css("a.dispatch-sidebar__nav-link.active", text: /Dashboard/)
  end

  context "when active_path is /deployments" do
    subject(:component) { described_class.new(user: user, active_path: "/deployments") }

    it "marks Deployments as active" do
      render_inline(component)
      expect(page).to have_css("a.dispatch-sidebar__nav-link.active", text: /Deployments/)
    end

    it "does not mark Dashboard as active" do
      render_inline(component)
      expect(page).not_to have_css("a.dispatch-sidebar__nav-link.active", text: /Dashboard/)
    end
  end

  it "renders the theme toggle" do
    render_inline(component)
    expect(page).to have_css("input[type='checkbox'][data-theme-toggle]")
  end

  it "renders the user profile section" do
    render_inline(component)
    expect(page).to have_css(".dispatch-sidebar__user")
    expect(page).to have_text("Test User")
  end

  it "renders the email from settings" do
    render_inline(component)
    expect(page).to have_text("testuser@stanford.edu")
  end

  it "renders initials when no avatar is available" do
    render_inline(component)
    expect(page).to have_css(".dispatch-sidebar__avatar", text: "TU")
  end

  context "when the user has a github username" do
    let(:user) do
      instance_double(UserPresenter,
        name:               "Test User",
        email:              "testuser@stanford.edu",
        initials:           "TU",
        avatar_url:         "https://github.com/octocat.png?size=56",
        github_profile_url: "https://github.com/octocat",
        github_username:    "octocat")
    end

    it "renders the github avatar image" do
      render_inline(component)
      expect(page).to have_css("img[src*='github.com/octocat.png']")
    end

    it "links the avatar to the github profile opening in a new tab" do
      render_inline(component)
      expect(page).to have_css("a[href='https://github.com/octocat'][target='_blank']")
    end

    it "links the name to the github profile" do
      render_inline(component)
      expect(page).to have_css("a[href='https://github.com/octocat']", text: "Test User")
    end
  end
end
