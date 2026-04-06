require "rails_helper"

RSpec.describe SetupIntegrationTestSuiteJob, type: :job do
  let(:repo_path) { Rails.root.join("tmp/infrastructure-integration-test") }
  let(:spec_files) do
    [
      repo_path.join("spec/features/argo_spec.rb").to_s,
      repo_path.join("spec/features/dor_services_app_spec.rb").to_s
    ]
  end

  let(:system_calls) { [] }

  before do
    allow(FileUtils).to receive(:rm_rf)
    allow_any_instance_of(described_class).to receive(:system) { |_, *args| system_calls << args.find { |a| a.is_a?(String) } } # rubocop:disable RSpec/AnyInstance
    allow(Dir).to receive(:chdir).with(repo_path).and_yield
    allow(Dir).to receive(:glob).and_return(spec_files)
    allow(IntegrationTestRunnerJob).to receive(:perform_later)
  end

  describe "#perform" do
    it "removes the existing repo directory" do
      described_class.perform_now
      expect(FileUtils).to have_received(:rm_rf).with(repo_path)
    end

    it "clones the infrastructure-integration-test repo" do
      described_class.perform_now
      expect(system_calls).to include(a_string_including("git clone").and(a_string_including("infrastructure-integration-test")))
    end

    it "runs bundle install" do
      described_class.perform_now
      expect(system_calls).to include("bundle install")
    end

    it "finds or creates an IntegrationTest for each spec file" do
      expect { described_class.perform_now }.to change(IntegrationTest, :count).by(2)
      expect(IntegrationTest.pluck(:name)).to include("argo", "dor_services_app")
    end

    it "creates a TestRun for each IntegrationTest" do
      expect { described_class.perform_now }.to change(TestRun, :count).by(2)
    end

    it "enqueues IntegrationTestRunnerJob for each TestRun" do
      described_class.perform_now
      expect(IntegrationTestRunnerJob).to have_received(:perform_later).twice
    end

    it "does not duplicate IntegrationTest records when run twice" do
      create(:integration_test, name: "argo")
      expect { described_class.perform_now }.to change(IntegrationTest, :count).by(1)
    end
  end
end
