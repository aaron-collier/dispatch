require "rails_helper"

RSpec.describe UpdatePullRequest, type: :model do
  subject { build(:update_pull_request) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:pull_request) }
    it { is_expected.to validate_uniqueness_of(:pull_request) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:repository) }
  end

  describe "enums" do
    it "defines status values" do
      expect(described_class.statuses).to eq({ "open" => 0, "closed" => 1, "merged" => 2 })
    end

    it "defines build values" do
      expect(described_class.builds).to eq({ "passing" => 0, "failing" => 1, "building" => 2 })
    end
  end

  describe "status prefix helpers" do
    subject(:pr) { create(:update_pull_request, status: :open) }

    it "responds to status_open?" do
      expect(pr.status_open?).to be(true)
    end

    it "responds to build_passing?" do
      expect(pr.build_passing?).to be(true)
    end
  end

  describe "scopes" do
    it "scopes to open status" do
      open_pr   = create(:update_pull_request, status: :open)
      _closed   = create(:update_pull_request, :closed)
      expect(described_class.status_open).to contain_exactly(open_pr)
    end

    it "scopes to passing build" do
      passing   = create(:update_pull_request, build: :passing)
      _failing  = create(:update_pull_request, :failing)
      expect(described_class.build_passing).to contain_exactly(passing)
    end
  end
end
