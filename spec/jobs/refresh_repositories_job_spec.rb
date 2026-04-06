require "rails_helper"

RSpec.describe RefreshRepositoriesJob, type: :job do
  let(:yaml_content) do
    <<~YAML
      repositories:
        - name: sul-dlss/argo
          cocina_models_update: true
        - name: sul-dlss/speech-to-text
          exclude_envs:
            - prod
            - stage
          skip_audit: true
        - name: sul-dlss/dlme-airflow
          non_standard_envs:
            - dev
    YAML
  end

  before do
    allow(Net::HTTP).to receive(:get).and_return(yaml_content)
    allow(FetchDependencyUpdatesJob).to receive(:perform_later)
    allow(Settings).to receive(:merge_only_repositories).and_return([ "sul-dlss/dlme-airflow" ])
  end

  describe "#perform" do
    it "creates Repository records from the YAML" do
      expect { described_class.perform_now }.to change(Repository, :count).by(3)
    end

    it "sets cocina_models_update correctly" do
      described_class.perform_now
      expect(Repository.find_by(name: "sul-dlss/argo").cocina_models_update).to be(true)
    end

    it "sets exclude_envs as an array" do
      described_class.perform_now
      expect(Repository.find_by(name: "sul-dlss/speech-to-text").exclude_envs).to eq([ "prod", "stage" ])
    end

    it "sets non_standard_envs as an array" do
      described_class.perform_now
      expect(Repository.find_by(name: "sul-dlss/dlme-airflow").non_standard_envs).to eq([ "dev" ])
    end

    it "sets skip_audit correctly" do
      described_class.perform_now
      expect(Repository.find_by(name: "sul-dlss/speech-to-text").skip_audit).to be(true)
    end

    it "updates an existing record rather than creating a duplicate" do
      create(:repository, name: "sul-dlss/argo", cocina_models_update: false)
      described_class.perform_now
      expect(Repository.where(name: "sul-dlss/argo").count).to eq(1)
      expect(Repository.find_by(name: "sul-dlss/argo").cocina_models_update).to be(true)
    end

    it "sets merge_only to true for repos in Settings.merge_only_repositories" do
      described_class.perform_now
      expect(Repository.find_by(name: "sul-dlss/dlme-airflow").merge_only).to be(true)
    end

    it "sets merge_only to false for repos not in Settings.merge_only_repositories" do
      described_class.perform_now
      expect(Repository.find_by(name: "sul-dlss/argo").merge_only).to be(false)
    end

    it "enqueues FetchDependencyUpdatesJob after completing" do
      described_class.perform_now
      expect(FetchDependencyUpdatesJob).to have_received(:perform_later)
    end

    context "when the remote URL fails" do
      before do
        allow(Net::HTTP).to receive(:get).and_raise(StandardError, "network error")
      end

      it "does not raise an error" do
        expect { described_class.perform_now }.not_to raise_error
      end

      it "does not enqueue FetchDependencyUpdatesJob" do
        described_class.perform_now
        expect(FetchDependencyUpdatesJob).not_to have_received(:perform_later)
      end
    end
  end
end
