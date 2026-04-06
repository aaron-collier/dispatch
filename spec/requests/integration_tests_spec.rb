require "rails_helper"

RSpec.describe "IntegrationTests", type: :request do
  let(:integration_test) { create(:integration_test) }

  describe "GET /integration_tests" do
    it "returns http success" do
      get integration_tests_path
      expect(response).to have_http_status(:success)
    end

    it "renders the stability overview" do
      get integration_tests_path
      expect(response.body).to include("Stability Overview")
    end

    it "renders the RUN TESTS button" do
      get integration_tests_path
      expect(response.body).to include("RUN TESTS")
    end
  end

  describe "GET /integration_tests/:id" do
    it "returns http success" do
      get integration_test_path(integration_test)
      expect(response).to have_http_status(:success)
    end

    it "renders the test name" do
      get integration_test_path(integration_test)
      expect(response.body).to include(integration_test.name)
    end

    it "renders the RUN TEST button" do
      get integration_test_path(integration_test)
      expect(response.body).to include("RUN TEST")
    end
  end

  describe "POST /integration_tests/run" do
    before { allow(SetupIntegrationTestSuiteJob).to receive(:perform_later) }

    it "enqueues SetupIntegrationTestSuiteJob" do
      post run_integration_tests_path
      expect(SetupIntegrationTestSuiteJob).to have_received(:perform_later)
    end

    it "responds with a turbo stream" do
      post run_integration_tests_path
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end
  end

  describe "POST /integration_tests/:id/run" do
    before { allow(IntegrationTestRunnerJob).to receive(:perform_later) }

    it "creates a new TestRun with queuing status" do
      expect { post run_integration_test_path(integration_test) }.to change(TestRun, :count).by(1)
      expect(TestRun.last.status).to eq("queuing")
    end

    it "enqueues IntegrationTestRunnerJob" do
      post run_integration_test_path(integration_test)
      expect(IntegrationTestRunnerJob).to have_received(:perform_later).with(TestRun.last.id)
    end

    it "redirects to the test show page" do
      post run_integration_test_path(integration_test)
      expect(response).to redirect_to(integration_test_path(integration_test))
    end
  end
end
