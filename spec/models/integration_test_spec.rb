require "rails_helper"

RSpec.describe IntegrationTest, type: :model do
  subject { build(:integration_test) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:test_runs).dependent(:destroy) }
  end
end
