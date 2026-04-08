require "rails_helper"

RSpec.describe IntegrationTestRunnerJob, type: :job do
  let(:integration_test) { create(:integration_test, name: "argo") }
  let(:test_run)         { create(:test_run, integration_test: integration_test) }
  let(:repo_path)        { Rails.root.join("tmp/infrastructure-integration-test") }
  let(:settings_file)    { repo_path.join("config/settings/stage.local.yml") }
  let(:spec_file)        { repo_path.join("spec/features/argo_spec.rb").to_s }

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  describe "#perform" do
    context "when the test directory exists and rspec passes" do
      before do
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(true)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(settings_file).and_return(true)
        allow(Dir).to receive(:glob).and_call_original
        allow(Dir).to receive(:glob).with(repo_path.join("spec/features/*_spec.rb").to_s).and_return([ spec_file ])
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

      it "runs rspec only once when it passes immediately" do
        described_class.perform_now(test_run.id)
        expect(Open3).to have_received(:capture2e).once
      end
    end

    context "when the test directory exists and rspec always fails" do
      let(:max_retries) { 2 }

      before do
        allow(Settings).to receive(:max_retries_on_failure).and_return(max_retries)
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(true)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(settings_file).and_return(true)
        allow(Dir).to receive(:glob).and_call_original
        allow(Dir).to receive(:glob).with(repo_path.join("spec/features/*_spec.rb").to_s).and_return([ spec_file ])
        allow(Open3).to receive(:capture2e).and_return([ "1 example, 1 failure", double(success?: false) ])
      end

      it "transitions the test run to failed" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.status).to eq("failed")
      end

      it "saves the rspec output from the last attempt" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.output).to eq("1 example, 1 failure")
      end

      it "runs rspec max_retries + 1 times before giving up" do
        described_class.perform_now(test_run.id)
        expect(Open3).to have_received(:capture2e).exactly(max_retries + 1).times
      end

      it "does not update the status to failed until all retries are exhausted" do
        statuses_during_run = []
        allow(Open3).to receive(:capture2e) do
          statuses_during_run << test_run.reload.status
          [ "1 example, 1 failure", double(success?: false) ]
        end
        described_class.perform_now(test_run.id)
        expect(statuses_during_run).to all(eq("running"))
        expect(test_run.reload.status).to eq("failed")
      end
    end

    context "when rspec fails initially but passes on a retry" do
      let(:max_retries) { 2 }

      before do
        allow(Settings).to receive(:max_retries_on_failure).and_return(max_retries)
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(true)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(settings_file).and_return(true)
        allow(Dir).to receive(:glob).and_call_original
        allow(Dir).to receive(:glob).with(repo_path.join("spec/features/*_spec.rb").to_s).and_return([ spec_file ])
        allow(Open3).to receive(:capture2e).and_return(
          [ "1 example, 1 failure", double(success?: false) ],
          [ "1 example, 0 failures", double(success?: true) ]
        )
      end

      it "transitions the test run to passed" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.status).to eq("passed")
      end

      it "saves the output from the passing run" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.output).to eq("1 example, 0 failures")
      end

      it "stops retrying once the test passes" do
        described_class.perform_now(test_run.id)
        expect(Open3).to have_received(:capture2e).twice
      end

      it "does not update status to failed during the failing attempt" do
        statuses_during_run = []
        call_count = 0
        allow(Open3).to receive(:capture2e) do
          statuses_during_run << test_run.reload.status
          call_count += 1
          call_count == 1 ? [ "1 example, 1 failure", double(success?: false) ] : [ "1 example, 0 failures", double(success?: true) ]
        end
        described_class.perform_now(test_run.id)
        expect(statuses_during_run).to all(eq("running"))
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

    context "when the settings file is missing" do
      before do
        allow(Dir).to receive(:exist?).and_call_original
        allow(Dir).to receive(:exist?).with(repo_path).and_return(true)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(settings_file).and_return(false)
      end

      it "transitions the test run to failed" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.status).to eq("failed")
      end

      it "saves an appropriate error message as output" do
        described_class.perform_now(test_run.id)
        expect(test_run.reload.output).to include("stage.local.yml")
      end

      it "does not attempt to run rspec" do
        described_class.perform_now(test_run.id)
        expect(Open3).not_to receive(:capture2e)
      end
    end
  end
end
