require "rails_helper"

RSpec.describe Dashboard::DataTableComponent, type: :component do
  let(:rows) do
    [
      DashboardPresenter::IntegrationTestRow.new(name: "argo_accession",  status: "passed",  fail_rate: nil, last_run: "2h ago"),
      DashboardPresenter::IntegrationTestRow.new(name: "sul_pub_publish", status: "failed",  fail_rate: nil, last_run: "4h ago"),
      DashboardPresenter::IntegrationTestRow.new(name: "cocina_check",    status: nil,       fail_rate: nil, last_run: nil)
    ]
  end

  subject(:component) { described_class.new(rows: rows) }

  it "renders a table" do
    render_inline(component)
    expect(page).to have_css("table.dispatch-table")
  end

  it "renders all rows" do
    render_inline(component)
    expect(page).to have_css("tbody tr", count: 3)
  end

  it "renders test names in monospace" do
    render_inline(component)
    expect(page).to have_css("span.dispatch-table__name.font-mono", text: "argo_accession")
  end

  it "renders the Status header" do
    render_inline(component)
    expect(page).to have_css("th", text: "Status")
  end

  it "renders the Last Run header" do
    render_inline(component)
    expect(page).to have_css("th", text: "Last Run")
  end

  it "renders status badges for rows with a status" do
    render_inline(component)
    expect(page).to have_css("span.badge", text: "passed")
    expect(page).to have_css("span.badge", text: "failed")
  end

  it "renders a dash when status is nil" do
    render_inline(component)
    expect(page).to have_css(".dispatch-table__muted", text: "—")
  end

  it "renders last run timestamps" do
    render_inline(component)
    expect(page).to have_text("2h ago")
  end

  it "renders a dash for nil fail_rate" do
    render_inline(component)
    expect(page).to have_text("—")
  end

  it "has the turbo stream target id" do
    render_inline(component)
    expect(page).to have_css("#integration_tests_table")
  end
end
