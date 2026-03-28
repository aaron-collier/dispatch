require "rails_helper"

RSpec.describe Deployment, type: :model do
  subject { build(:deployment) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:revision) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:repository) }
  end

  describe "enums" do
    it "defines environment values" do
      expect(described_class.environments).to eq({ "prod" => 0, "stage" => 1, "qa" => 2 })
    end
  end

  describe "uniqueness" do
    it "does not allow duplicate revision + environment per repository" do
      repo = create(:repository)
      create(:deployment, repository: repo, revision: "abc123", environment: :prod)
      duplicate = build(:deployment, repository: repo, revision: "abc123", environment: :prod)
      expect(duplicate).not_to be_valid
    end

    it "allows the same revision in different environments" do
      repo = create(:repository)
      create(:deployment, repository: repo, revision: "abc123", environment: :prod)
      other = build(:deployment, repository: repo, revision: "abc123", environment: :stage)
      expect(other).to be_valid
    end
  end
end
