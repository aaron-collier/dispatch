require "rails_helper"

RSpec.describe DeploymentsPresenter do
  let(:repo_a) { create(:repository, name: "sul-dlss/argo") }
  let(:repo_b) { create(:repository, name: "sul-dlss/sul-pub") }

  describe "#table_rows" do
    context "with the default period (last_month)" do
      subject(:presenter) { described_class.new }

      before do
        create(:deployment, repository: repo_a, environment: :prod, date: 1.week.ago)
        create(:deployment, repository: repo_a, environment: :prod, date: 2.weeks.ago, revision: "rev2")
        create(:deployment, repository: repo_b, environment: :stage, date: 3.weeks.ago)
        create(:deployment, repository: repo_b, environment: :prod, date: 3.months.ago, revision: "old") # outside range
      end

      it "returns rows for deployments within the last month" do
        names = presenter.table_rows.map(&:name)
        expect(names).to include("argo")
        expect(names).to include("sul-pub")
      end

      it "strips the sul-dlss/ prefix from repository names" do
        names = presenter.table_rows.map(&:name)
        expect(names).not_to include("sul-dlss/argo")
      end

      it "sorts rows by count descending" do
        rows = presenter.table_rows
        counts = rows.map(&:count)
        expect(counts).to eq(counts.sort.reverse)
      end

      it "excludes deployments outside the period" do
        prod_rows = presenter.table_rows.select { |r| r.name == "sul-pub" && r.env == "prod" }
        expect(prod_rows).to be_empty
      end
    end

    context "with all_time period" do
      subject(:presenter) { described_class.new(period: "all_time") }

      before do
        create(:deployment, repository: repo_a, date: 6.months.ago)
        create(:deployment, repository: repo_b, date: 2.years.ago, revision: "rev_old")
      end

      it "includes all deployments regardless of date" do
        names = presenter.table_rows.map(&:name)
        expect(names).to include("argo")
        expect(names).to include("sul-pub")
      end
    end

    context "with an unknown period" do
      subject(:presenter) { described_class.new(period: "bogus") }

      it "defaults to last_month" do
        expect(presenter.selected_label).to eq("Last Month")
      end
    end
  end

  describe "#activity_feed" do
    subject(:presenter) { described_class.new }

    before do
      create(:deployment, repository: repo_a, date: 1.hour.ago)
      create(:deployment, repository: repo_b, date: 2.days.ago)
    end

    it "returns activity items for each repository that has deployments" do
      names = presenter.activity_feed.map(&:message)
      expect(names).to include("argo")
      expect(names).to include("sul-pub")
    end

    it "sorts alphabetically by repository name" do
      names = presenter.activity_feed.map(&:message)
      expect(names).to eq(names.sort)
    end

    it "strips the sul-dlss/ prefix" do
      names = presenter.activity_feed.map(&:message)
      expect(names).not_to include("sul-dlss/argo")
    end

    it "returns ActivityItem structs with the expected icon" do
      item = presenter.activity_feed.first
      expect(item.icon).to eq("bi-rocket-takeoff")
    end
  end

  describe "#filter_options" do
    subject(:presenter) { described_class.new }

    it "returns four filter options" do
      expect(presenter.filter_options.length).to eq(4)
    end

    it "includes Last Month, Last Week, Last 90 Days, and All Time" do
      labels = presenter.filter_options.map { |o| o[:label] }
      expect(labels).to contain_exactly("Last Month", "Last Week", "Last 90 Days", "All Time")
    end
  end

  describe "#selected_label" do
    it "returns Last Month by default" do
      expect(described_class.new.selected_label).to eq("Last Month")
    end

    it "returns the matching label for a valid period" do
      expect(described_class.new(period: "last_week").selected_label).to eq("Last Week")
    end
  end

  describe "time_ago formatting" do
    subject(:presenter) { described_class.new(period: "all_time") }

    it "formats seconds" do
      repo = create(:repository)
      create(:deployment, repository: repo, date: 30.seconds.ago)
      row = presenter.table_rows.first
      expect(row.last_deployed).to match(/\d+s ago/)
    end

    it "formats minutes" do
      repo = create(:repository)
      create(:deployment, repository: repo, date: 5.minutes.ago)
      row = presenter.table_rows.first
      expect(row.last_deployed).to match(/\d+m ago/)
    end

    it "formats hours" do
      repo = create(:repository)
      create(:deployment, repository: repo, date: 3.hours.ago)
      row = presenter.table_rows.first
      expect(row.last_deployed).to match(/\d+h ago/)
    end

    it "formats days" do
      repo = create(:repository)
      create(:deployment, repository: repo, date: 5.days.ago)
      row = presenter.table_rows.first
      expect(row.last_deployed).to match(/\d+d ago/)
    end

    it "formats months" do
      repo = create(:repository)
      create(:deployment, repository: repo, date: 3.months.ago)
      row = presenter.table_rows.first
      expect(row.last_deployed).to match(/\d+mo ago/)
    end
  end
end
