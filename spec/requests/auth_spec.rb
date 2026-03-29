require "rails_helper"

RSpec.describe "Auth", type: :request do
  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(ApplicationController).to receive(:render).and_return("<div></div>")
  end

  describe "GET /auth/new" do
    it "returns http success" do
      get new_auth_path
      expect(response).to have_http_status(:success)
    end

    it "renders the auth page" do
      get new_auth_path
      expect(response.body).to include("Authentication Required")
    end

    it "includes a link to the configured auth URL" do
      get new_auth_path
      expect(response.body).to include(Settings.auth.url)
    end
  end

  describe "POST /auth" do
    it "creates an auth SystemStatus record" do
      expect { post auth_path }.to change(SystemStatus, :count).by(1)
    end

    it "sets connected: true with an expiry" do
      post auth_path
      status = SystemStatus.find_by(name: "auth")
      expect(status.connected).to be(true)
      expect(status.expires_at).to be > Time.current
    end

    it "sets expires_at based on configured ttl_hours" do
      post auth_path
      status = SystemStatus.find_by(name: "auth")
      expected_expiry = Time.current + Settings.auth.ttl_hours.hours
      expect(status.expires_at).to be_within(5.seconds).of(expected_expiry)
    end

    it "broadcasts a Turbo Stream update" do
      post auth_path
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "system_status",
        target: "auth_indicator",
        html: anything
      )
    end

    it "redirects to the dashboard" do
      post auth_path
      expect(response).to redirect_to(root_path)
    end

    it "updates an existing auth record rather than creating a duplicate" do
      SystemStatus.create!(name: "auth", connected: false, expires_at: 1.hour.ago)
      expect { post auth_path }.not_to change(SystemStatus, :count)
      expect(SystemStatus.find_by(name: "auth").connected).to be(true)
    end
  end

  describe "GET /auth/callback" do
    it "marks auth as authenticated and redirects to dashboard" do
      get callback_auth_path
      expect(SystemStatus.find_by(name: "auth").connected).to be(true)
      expect(response).to redirect_to(root_path)
    end
  end
end
