require "rails_helper"

RSpec.describe Fault, type: :model do
  subject { build(:fault) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:revision) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:honeybadger_id) }
    it { is_expected.to validate_uniqueness_of(:honeybadger_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:repository) }
  end

  describe "enums" do
    it "defines environment values" do
      expect(described_class.environments).to eq({ "prod" => 0, "stage" => 1, "qa" => 2 })
    end
  end
end
