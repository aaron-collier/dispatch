require "rails_helper"

RSpec.describe IntegrationTestRunnerJob, type: :job do
  let(:integration_test) { create(:integration_test, name: "argo") }
  let(:test_run)         { create(:test_run, integration_test: integration_test) }
  let(:repo_path)        { Rails.root.join("tmp/infrastructure-integration-test") }

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  describe "#perform" do
    context "when the test directory exists and rspec passes" do
      before do
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(true)
        allow(Dir).to receive(:chdir).with(repo_path).and_yield
        allow(Open3).to receive(:capture2e).and_return([ "1 example, 0 failures", double(success?: true) ])
      end

      it "transitions the test run from queuing to running to passed" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.status).to eq("passed")
      end

      it "saves the rspec output" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.output).to eq("1 example, 0 failures")
      end

      it "broadcasts twice (running + passed)" do
        described_class.perform_now(test_run.id)
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to)
          .with("integration_tests", target: "integration_tests_table", html: anything).twice
      end

      it "broadcasts the test run row update" do
        described_class.perform_now(test_run.id)
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to)
          .with("integration_tests", target: "test_run_#{test_run.id}", html: anything).twice
      end
    end

    context "when the test directory exists and rspec fails" do
      before do
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(true)
        allow(Dir).to receive(:chdir).with(repo_path).and_yield
        allow(Open3).to receive(:capture2e).and_return([ "1 example, 1 failure", double(success?: false) ])
      end

      it "transitions the test run to failed" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.status).to eq("failed")
      end

      it "saves the rspec output" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.output).to eq("1 example, 1 failure")
      end
    end

    context "when the test directory does not exist" do
      before do
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(false)
      end

      it "transitions the test run to failed" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.status).to eq("failed")
      end

      it "saves an appropriate error message as output" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.output).to include("not found")
      end

      it "does not attempt to run rspec" do
        described_class.perform_now(test_run.id)
        expect(Open3).not_to receive(:capture2e)
      end
    end
  end
end
