require "rails_helper"

RSpec.describe Repository, type: :model do
  subject { build(:repository) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:update_pull_requests).dependent(:destroy) }
  end

  describe "serialization" do
    it "stores and retrieves exclude_envs as an array" do
      repo = create(:repository, exclude_envs: [ "prod", "stage" ])
      expect(repo.reload.exclude_envs).to eq([ "prod", "stage" ])
    end

    it "stores and retrieves non_standard_envs as an array" do
      repo = create(:repository, non_standard_envs: [ "dev" ])
      expect(repo.reload.non_standard_envs).to eq([ "dev" ])
    end

    it "handles nil exclude_envs" do
      repo = create(:repository, exclude_envs: nil)
      expect(repo.reload.exclude_envs).to be_nil
    end
  end

  describe ".for" do
    it "returns an existing record by name" do
      existing = create(:repository, name: "sul-dlss/argo")
      expect(described_class.for("sul-dlss/argo")).to eq(existing)
    end

    it "initializes a new record when none exists" do
      record = described_class.for("sul-dlss/new-repo")
      expect(record).to be_a_new(described_class)
      expect(record.name).to eq("sul-dlss/new-repo")
    end
  end
end
