require "rails_helper"

RSpec.describe TestRunStatsPresenter do
  subject(:presenter) { described_class.new(period: "last_month") }

  describe "#period_options" do
    it "returns an array with label/value hashes" do
      expect(presenter.period_options).to include(
        hash_including(label: "Last Month", value: "last_month"),
        hash_including(label: "Last Week",  value: "last_week")
      )
    end
  end

  describe "#selected_period_label" do
    it "returns the label for the selected period" do
      expect(presenter.selected_period_label).to eq("Last Month")
    end

    it "defaults to Last Month for an unknown period" do
      p = described_class.new(period: "bogus")
      expect(p.selected_period_label).to eq("Last Month")
    end
  end

  describe "#health_score" do
    context "with no test runs" do
      it "returns score 0 and No Data label" do
        expect(presenter.health_score).to eq({ score: 0, label: "No Data" })
      end
    end

    context "with all-passing tests" do
      before do
        test = create(:integration_test)
        create(:test_run, integration_test: test, status: "passed")
      end

      it "returns score 100" do
        expect(presenter.health_score[:score]).to eq(100)
      end

      it "returns Excellent label" do
        expect(presenter.health_score[:label]).to eq("Excellent")
      end
    end

    context "with a mix of passing, flaky, and failing tests" do
      before do
        passing_test = create(:integration_test, name: "passing_test")
        create(:test_run, integration_test: passing_test, status: "passed")

        flaky_test = create(:integration_test, name: "flaky_test")
        create(:test_run, integration_test: flaky_test, status: "passed")
        create(:test_run, integration_test: flaky_test, status: "failed")

        failing_test = create(:integration_test, name: "failing_test")
        create(:test_run, integration_test: failing_test, status: "failed")
      end

      it "calculates score as passing_count / total_tested * 100" do
        # 1 passing out of 3 total = 33%
        expect(presenter.health_score[:score]).to eq(33)
      end
    end
  end

  describe "#health_segments" do
    before do
      passing_test = create(:integration_test, name: "passing_test")
      create(:test_run, integration_test: passing_test, status: "passed")

      flaky_test = create(:integration_test, name: "flaky_test")
      create(:test_run, integration_test: flaky_test, status: "passed")
      create(:test_run, integration_test: flaky_test, status: "failed")

      failing_test = create(:integration_test, name: "failing_test")
      create(:test_run, integration_test: failing_test, status: "failed")
    end

    it "returns three segments" do
      expect(presenter.health_segments.length).to eq(3)
    end

    it "reports correct passing count" do
      passing = presenter.health_segments.find { |s| s[:label] == "Passing" }
      expect(passing[:value]).to eq(1)
    end

    it "reports correct flaky count" do
      flaky = presenter.health_segments.find { |s| s[:label] == "Flaky" }
      expect(flaky[:value]).to eq(1)
    end

    it "reports correct failing count" do
      failing = presenter.health_segments.find { |s| s[:label] == "Failing" }
      expect(failing[:value]).to eq(1)
    end
  end

  describe "#test_rows" do
    let!(:integration_test) { create(:integration_test, name: "argo_accession") }

    before do
      create(:test_run, integration_test: integration_test, status: "passed",
                        created_at: 2.hours.ago)
      create(:test_run, integration_test: integration_test, status: "failed",
                        created_at: 1.hour.ago)
    end

    it "returns DashboardPresenter::IntegrationTestRow objects" do
      expect(presenter.test_rows.first).to be_a(DashboardPresenter::IntegrationTestRow)
    end

    it "populates name" do
      expect(presenter.test_rows.first.name).to eq("argo_accession")
    end

    it "populates fail_rate" do
      expect(presenter.test_rows.first.fail_rate).to eq(50.0)
    end

    it "populates last_run as a time-ago string" do
      expect(presenter.test_rows.first.last_run).to match(/ago/)
    end

    it "returns the status of the most recent test run" do
      expect(presenter.test_rows.first.status).to eq("failed")
    end

    context "when a test has only passing runs" do
      let!(:passing_test) { create(:integration_test, name: "sul_pub") }

      before { create(:test_run, integration_test: passing_test, status: "passed") }

      it "returns passed status" do
        row = presenter.test_rows.find { |r| r.name == "sul_pub" }
        expect(row.status).to eq("passed")
      end

      it "has 0.0 fail_rate" do
        row = presenter.test_rows.find { |r| r.name == "sul_pub" }
        expect(row.fail_rate).to eq(0.0)
      end
    end

    context "when a test has only failing runs" do
      let!(:failing_test) { create(:integration_test, name: "broken_spec") }

      before { create(:test_run, integration_test: failing_test, status: "failed") }

      it "returns failed status" do
        row = presenter.test_rows.find { |r| r.name == "broken_spec" }
        expect(row.status).to eq("failed")
      end
    end

    context "when a test has no runs in the period" do
      let!(:no_run_test) { create(:integration_test, name: "never_run") }

      it "returns nil status for tests with no runs" do
        row = presenter.test_rows.find { |r| r.name == "never_run" }
        expect(row.status).to be_nil
      end
    end
  end

  describe "period filtering" do
    let!(:test) { create(:integration_test, name: "time_filtered") }

    before do
      create(:test_run, integration_test: test, status: "passed", created_at: 2.months.ago)
    end

    it "excludes runs outside the period" do
      p = described_class.new(period: "last_week")
      expect(p.health_score).to eq({ score: 0, label: "No Data" })
    end

    it "includes runs within the period" do
      p = described_class.new(period: "last_90_days")
      expect(p.health_score[:score]).to eq(100)
    end
  end
end
