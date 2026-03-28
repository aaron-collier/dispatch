require "rails_helper"

RSpec.describe TestRun, type: :model do
  subject { build(:test_run) }

  describe "associations" do
    it { is_expected.to belong_to(:integration_test) }
  end

  describe "default status" do
    it "starts in the queuing state" do
      expect(subject.status).to eq("queuing")
    end
  end

  describe "AASM state machine" do
    let(:test_run) { create(:test_run) }

    describe "start event" do
      it "transitions from queuing to running" do
        test_run.start!
        expect(test_run.status).to eq("running")
      end

      it "raises when called from a non-queuing state" do
        test_run.start!
        expect { test_run.start! }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe "pass event" do
      before { test_run.start! }

      it "transitions from running to passed" do
        test_run.pass!
        expect(test_run.status).to eq("passed")
      end
    end

    describe "fail event" do
      before { test_run.start! }

      it "transitions from running to failed" do
        test_run.fail!
        expect(test_run.status).to eq("failed")
      end
    end

    describe "invalid transitions" do
      it "cannot go from queuing to passed directly" do
        expect { test_run.pass! }.to raise_error(AASM::InvalidTransition)
      end

      it "cannot go from queuing to failed directly" do
        expect { test_run.fail! }.to raise_error(AASM::InvalidTransition)
      end
    end
  end
end
