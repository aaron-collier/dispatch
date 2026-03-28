require "rails_helper"

RSpec.describe "Deployments", type: :request do
  describe "GET /deployments" do
    it "returns http success" do
      get deployments_path
      expect(response).to have_http_status(:success)
    end

    it "renders the deployments page" do
      get deployments_path
      expect(response.body).to include("dispatch-root")
    end

    it "includes the Deployments heading" do
      get deployments_path
      expect(response.body).to include("Deployments")
    end

    it "includes the Overview section" do
      get deployments_path
      expect(response.body).to include("Overview")
    end

    context "with deployment data" do
      let(:repo) { create(:repository, name: "sul-dlss/argo") }

      before { create(:deployment, repository: repo, date: 1.day.ago) }

      it "shows the repository name" do
        get deployments_path
        expect(response.body).to include("argo")
      end
    end

    context "when filtering by period" do
      let(:repo) { create(:repository, name: "sul-dlss/argo") }

      before do
        create(:deployment, repository: repo, date: 2.weeks.ago)
        create(:deployment, repository: repo, date: 2.months.ago, revision: "older")
      end

      it "accepts a period param without error" do
        get deployments_path, params: { period: "last_week" }
        expect(response).to have_http_status(:success)
      end

      it "defaults to last_month when no period is given" do
        get deployments_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
