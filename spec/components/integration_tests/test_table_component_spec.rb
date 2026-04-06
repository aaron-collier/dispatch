require "rails_helper"

RSpec.describe IntegrationTests::TestTableComponent, type: :component do
  include Rails.application.routes.url_helpers
  let(:test1) { create(:integration_test, name: "argo") }
  let(:test2) { create(:integration_test, name: "dor_services_app") }
  let(:rows) do
    [
      DashboardPresenter::IntegrationTestRow.new(name: "argo",            status: "passed", fail_rate: 0.0,  last_run: "2h ago"),
      DashboardPresenter::IntegrationTestRow.new(name: "dor_services_app", status: "failed", fail_rate: 50.0, last_run: "1d ago")
    ]
  end
  let(:tests) { { "argo" => test1, "dor_services_app" => test2 } }

  subject(:component) { described_class.new(rows: rows, tests: tests) }

  it "renders test names as links to the show page" do
    render_inline(component)
    expect(page).to have_link("ARGO",            href: integration_test_path(test1))
    expect(page).to have_link("DOR_SERVICES_APP", href: integration_test_path(test2))
  end

  it "renders status badges" do
    render_inline(component)
    expect(page).to have_content("PASSED")
    expect(page).to have_content("FAILED")
  end

  it "renders fail rates" do
    render_inline(component)
    expect(page).to have_content("0.0%")
    expect(page).to have_content("50.0%")
  end

  it "renders last run times" do
    render_inline(component)
    expect(page).to have_content("2h ago")
    expect(page).to have_content("1d ago")
  end
end
