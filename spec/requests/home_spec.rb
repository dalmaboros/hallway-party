# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home" do
  describe "GET /" do
    before { get root_path }

    context "when not signed in" do
      it "responds 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the GitHub sign-in button" do
        expect(response.body).to include("Sign in with GitHub")
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }
      let!(:event) { create(:event, :upcoming) }

      before do
        create(:event_attendance, user: user, event: event)
        create(:user_hobby, user: user)
        stub_github_auth(uid: user.uid)
        get "/auth/github/callback"
        get root_path
      end

      after { clear_github_auth }

      it "shows the dashboard link" do
        expect(response.body).to include("Go to dashboard")
      end

      it "greets the user by name" do
        expect(response.body).to include("Welcome back, #{user.name}")
      end
    end
  end
end
