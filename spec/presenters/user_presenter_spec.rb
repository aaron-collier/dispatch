require "rails_helper"

RSpec.describe UserPresenter do
  subject(:presenter) { described_class.new }

  describe "#name" do
    it "returns the configured name" do
      expect(presenter.name).to eq("Test User")
    end
  end

  describe "#sunetid" do
    it "returns the configured sunetid" do
      expect(presenter.sunetid).to eq("testuser")
    end
  end

  describe "#email" do
    it "appends @stanford.edu to the sunetid" do
      expect(presenter.email).to eq("testuser@stanford.edu")
    end
  end

  describe "#github_username" do
    it "returns the configured github username" do
      expect(presenter.github_username).to eq("octocat")
    end
  end

  describe "#avatar_url" do
    context "when a github username is configured" do
      it "returns the github avatar URL" do
        expect(presenter.avatar_url).to eq("https://github.com/octocat.png?size=56")
      end
    end

    context "when no github username is configured" do
      before { allow(Settings.github).to receive(:username).and_return(nil) }

      it "returns nil" do
        expect(presenter.avatar_url).to be_nil
      end
    end
  end

  describe "#github_profile_url" do
    context "when a github username is configured" do
      it "returns the github profile URL" do
        expect(presenter.github_profile_url).to eq("https://github.com/octocat")
      end
    end

    context "when no github username is configured" do
      before { allow(Settings.github).to receive(:username).and_return(nil) }

      it "returns nil" do
        expect(presenter.github_profile_url).to be_nil
      end
    end
  end

  describe "#initials" do
    it "returns the first letter of each word in the name, up to 2" do
      expect(presenter.initials).to eq("TU")
    end

    context "with a single-word name" do
      before { allow(Settings).to receive(:name).and_return("Aaron") }

      it "returns a single initial" do
        expect(presenter.initials).to eq("A")
      end
    end
  end
end
