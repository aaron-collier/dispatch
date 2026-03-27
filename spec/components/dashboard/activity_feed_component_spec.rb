require "rails_helper"

RSpec.describe Dashboard::ActivityFeedComponent, type: :component do
  let(:activities) do
    [
      DashboardPresenter::Activity.new(icon: "bi-git",          icon_color: "var(--dispatch-success)", message: "PR #481 merged to main",        timestamp: "3m ago",  actor: "aaronc"),
      DashboardPresenter::Activity.new(icon: "bi-shield-check", icon_color: "var(--dispatch-info)",    message: "Security scan passed",           timestamp: "12m ago", actor: "ci-bot")
    ]
  end

  subject(:component) { described_class.new(activities: activities) }

  it "renders a row for each activity" do
    render_inline(component)
    expect(page).to have_css(".dispatch-feed__item", count: 2)
  end

  it "renders the activity message" do
    render_inline(component)
    expect(page).to have_text("PR #481 merged to main")
  end

  it "renders the timestamp" do
    render_inline(component)
    expect(page).to have_text("3m ago")
    expect(page).to have_text("12m ago")
  end

  it "renders the icon class" do
    render_inline(component)
    expect(page).to have_css(".bi-git")
    expect(page).to have_css(".bi-shield-check")
  end
end
