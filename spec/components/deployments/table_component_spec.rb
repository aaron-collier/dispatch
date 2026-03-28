require "rails_helper"

RSpec.describe Deployments::TableComponent, type: :component do
  let(:rows) do
    [
      DeploymentsPresenter::TableRow.new(name: "argo", env: "prod", count: 12, last_deployed: "2h ago"),
      DeploymentsPresenter::TableRow.new(name: "sul-pub", env: "stage", count: 3, last_deployed: "1d ago")
    ]
  end

  subject(:component) { described_class.new(rows: rows) }

  it "renders the table headers" do
    render_inline(component)
    expect(page).to have_text("Repository")
    expect(page).to have_text("Env")
    expect(page).to have_text("Deployments")
    expect(page).to have_text("Last")
  end

  it "renders each row's repository name" do
    render_inline(component)
    expect(page).to have_text("argo")
    expect(page).to have_text("sul-pub")
  end

  it "renders each row's environment" do
    render_inline(component)
    expect(page).to have_text("prod")
    expect(page).to have_text("stage")
  end

  it "renders deployment counts" do
    render_inline(component)
    expect(page).to have_text("12")
    expect(page).to have_text("3")
  end

  it "renders last deployed times" do
    render_inline(component)
    expect(page).to have_text("2h ago")
    expect(page).to have_text("1d ago")
  end

  context "when there are no rows" do
    subject(:component) { described_class.new(rows: []) }

    it "shows an empty state message" do
      render_inline(component)
      expect(page).to have_text("No deployments found")
    end

    it "does not render a table" do
      render_inline(component)
      expect(page).not_to have_css("table")
    end
  end
end
