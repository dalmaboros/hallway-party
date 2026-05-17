# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard" do
  let(:user) { create(:user) }
  let!(:featured) { create(:event, :upcoming) }
  let(:knitting) { create(:hobby, name: "knitting") }

  before do
    create(:event_attendance, user: user, event: featured)
    create(:user_hobby, user: user, hobby: knitting)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
  end

  after { clear_github_auth }

  describe "GET /dashboard" do
    it "returns 200" do
      get dashboard_path
      expect(response).to have_http_status(:ok)
    end

    it "shows the user's name" do
      get dashboard_path
      expect(response.body).to include(user.name)
    end

    it "shows the user's username" do
      get dashboard_path
      expect(response.body).to include(user.username)
    end

    it "lists the user's hobbies" do
      get dashboard_path
      expect(response.body).to include("knitting")
    end

    it "sorts hobbies alphabetically" do
      create(:user_hobby, user: user, hobby: create(:hobby, name: "aardvark"))
      create(:user_hobby, user: user, hobby: create(:hobby, name: "zebra"))

      get dashboard_path
      expect(response.body.index("aardvark")).to be < response.body.index("zebra")
    end

    it "omits hobbies belonging to other users" do
      other_user = create(:user)
      create(:user_hobby, user: other_user, hobby: create(:hobby, name: "karate"))

      get dashboard_path
      expect(response.body).not_to include("karate")
    end
  end

  describe "GET /dashboard for a user whose events have all ended (soft sunset)" do
    before do
      # remove the outer setup's active attendance; this user now has only past events
      EventAttendance.destroy_all
      create(:event_attendance, user: user, event: create(:event, :past, name: "RailsConf 2025"))
    end

    it "renders the dashboard (does not redirect to onboarding)" do
      get dashboard_path
      expect(response).to have_http_status(:ok)
    end

    it "shows a retrospective callout naming the most recent past event" do
      get dashboard_path
      expect(response.body).to include("Thanks for being part of RailsConf 2025")
    end
  end
end
