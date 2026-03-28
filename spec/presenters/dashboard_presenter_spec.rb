require "rails_helper"

RSpec.describe DashboardPresenter do
  subject(:presenter) { described_class.new }

  describe "#integration_tests" do
    context "when there are no integration tests" do
      it "returns an empty array" do
        expect(presenter.integration_tests).to eq([])
      end
    end

    context "with integration test records" do
      before do
        create(:integration_test, name: "sul_pub_publish")
        create(:integration_test, name: "argo_accession")
      end

      it "returns one row per integration test" do
        expect(presenter.integration_tests.length).to eq(2)
      end

      it "returns rows sorted alphabetically by name" do
        names = presenter.integration_tests.map(&:name)
        expect(names).to eq(names.sort)
      end

      it "returns IntegrationTestRow structs" do
        row = presenter.integration_tests.first
        expect(row).to be_a(DashboardPresenter::IntegrationTestRow)
      end

      it "has nil status when no test runs exist" do
        row = presenter.integration_tests.first
        expect(row.status).to be_nil
      end
    end

    context "when an integration test has test runs" do
      let!(:integration_test) { create(:integration_test, name: "argo_accession") }

      before do
        create(:test_run, integration_test: integration_test, status: "passed",
                          created_at: 2.hours.ago)
        create(:test_run, integration_test: integration_test, status: "failed",
                          created_at: 1.hour.ago)
      end

      it "shows the status of the most recent test run" do
        row = presenter.integration_tests.first
        expect(row.status).to eq("failed")
      end
    end
  end
end
