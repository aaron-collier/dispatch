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
        expect(presenter.selected_period_label).to eq("Last Month")
      end
    end

    context "with env filter" do
      subject(:presenter) { described_class.new(period: "all_time", env: "prod") }

      before do
        create(:deployment, repository: repo_a, environment: :prod, date: 1.week.ago)
        create(:deployment, repository: repo_b, environment: :stage, date: 1.week.ago, revision: "rev_s")
      end

      it "only returns rows for the specified environment" do
        envs = presenter.table_rows.map(&:env)
        expect(envs).to all(eq("prod"))
      end

      it "excludes rows for other environments" do
        names = presenter.table_rows.map(&:name)
        expect(names).not_to include("sul-pub")
      end
    end

    context "with env=all (default)" do
      subject(:presenter) { described_class.new(period: "all_time", env: "all") }

      before do
        create(:deployment, repository: repo_a, environment: :prod,  date: 1.week.ago)
        create(:deployment, repository: repo_a, environment: :stage, date: 1.week.ago, revision: "rev_s")
      end

      it "returns rows for all environments" do
        envs = presenter.table_rows.map(&:env)
        expect(envs).to include("prod", "stage")
      end
    end

    context "with an unknown env" do
      subject(:presenter) { described_class.new(env: "bogus") }

      it "defaults to all" do
        expect(presenter.selected_env_label).to eq("All")
      end
    end
  end

  describe "#activity_feed" do
    subject(:presenter) { described_class.new }

    before do
      create(:deployment, repository: repo_a, environment: :prod, date: 1.hour.ago)
      create(:deployment, repository: repo_b, environment: :stage, date: 2.days.ago)
    end

    it "returns one item per repository" do
      expect(presenter.activity_feed.length).to eq(2)
    end

    it "includes the environment and user in the message" do
      messages = presenter.activity_feed.map(&:message)
      expect(messages).to include(a_string_matching(/\Aargo \(prod, \w+\)\z/))
    end

    it "sorts alphabetically by repository name" do
      messages = presenter.activity_feed.map(&:message)
      names = messages.map { |m| m.sub(/\s\(.*\)$/, "") }
      expect(names).to eq(names.sort)
    end

    it "strips the sul-dlss/ prefix" do
      messages = presenter.activity_feed.map(&:message)
      expect(messages).not_to include(a_string_starting_with("sul-dlss/"))
    end

    it "shows the env and user of the most recent deployment when a repo has multiple" do
      create(:deployment, repository: repo_a, environment: :stage, date: 30.minutes.ago,
                          revision: "newer", user: "deploy-bot")
      item = presenter.activity_feed.find { |a| a.message.start_with?("argo") }
      expect(item.message).to eq("argo (stage, deploy-bot)")
    end

    it "returns ActivityItem structs with the expected icon" do
      expect(presenter.activity_feed.first.icon).to eq("bi-rocket-takeoff")
    end
  end

  describe "#period_options" do
    subject(:presenter) { described_class.new }

    it "returns four period options" do
      expect(presenter.period_options.length).to eq(4)
    end

    it "includes Last Month, Last Week, Last 90 Days, and All Time" do
      labels = presenter.period_options.map { |o| o[:label] }
      expect(labels).to contain_exactly("Last Month", "Last Week", "Last 90 Days", "All Time")
    end
  end

  describe "#env_options" do
    subject(:presenter) { described_class.new }

    it "returns four env options" do
      expect(presenter.env_options.length).to eq(4)
    end

    it "includes All, Production, Stage, and QA" do
      labels = presenter.env_options.map { |o| o[:label] }
      expect(labels).to contain_exactly("All", "Production", "Stage", "QA")
    end
  end

  describe "#selected_period_label" do
    it "returns Last Month by default" do
      expect(described_class.new.selected_period_label).to eq("Last Month")
    end

    it "returns the matching label for a valid period" do
      expect(described_class.new(period: "last_week").selected_period_label).to eq("Last Week")
    end
  end

  describe "#selected_env_label" do
    it "returns All by default" do
      expect(described_class.new.selected_env_label).to eq("All")
    end

    it "returns Production for prod" do
      expect(described_class.new(env: "prod").selected_env_label).to eq("Production")
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
