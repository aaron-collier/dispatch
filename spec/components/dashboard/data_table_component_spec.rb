require "rails_helper"

RSpec.describe Dashboard::DataTableComponent, type: :component do
  let(:rows) do
    [
      DashboardPresenter::FlakeyTest.new(name: "UserAuthFlow#login_with_sso", suite: "auth",     fail_rate: 38, last_seen: "2h ago"),
      DashboardPresenter::FlakeyTest.new(name: "PaymentController#charge",    suite: "payments", fail_rate: 24, last_seen: "4h ago")
    ]
  end

  subject(:component) { described_class.new(rows: rows) }

  it "renders a table" do
    render_inline(component)
    expect(page).to have_css("table.dispatch-table")
  end

  it "renders all rows" do
    render_inline(component)
    expect(page).to have_css("tbody tr", count: 2)
  end

  it "renders test names in monospace" do
    render_inline(component)
    expect(page).to have_css("span.dispatch-table__name.font-mono", text: "UserAuthFlow#login_with_sso")
  end

  it "renders suite badges" do
    render_inline(component)
    expect(page).to have_text("auth")
    expect(page).to have_text("payments")
  end

  it "renders fail rates with danger color" do
    render_inline(component)
    expect(page).to have_css(".dispatch-table__fail", text: "38%")
  end

  it "renders last seen timestamps" do
    render_inline(component)
    expect(page).to have_text("2h ago")
  end
end
