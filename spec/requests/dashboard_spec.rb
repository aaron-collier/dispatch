require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "renders the dashboard" do
      get root_path
      expect(response.body).to include("dispatch-root")
    end

    it "enqueues FetchDependencyUpdatesJob on each load" do
      ActiveJob::Base.queue_adapter = :test
      expect { get root_path }.to have_enqueued_job(FetchDependencyUpdatesJob)
    ensure
      ActiveJob::Base.queue_adapter = :async
    end
  end
end
