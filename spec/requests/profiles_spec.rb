# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Profiles" do
  let(:user) { create(:user) }
  let!(:event) { create(:event, :upcoming) }
  let(:other) do
    create(
      :user,
      name: "Casey Profile",
      username: "casey",
      bio: "loves bouldering and homemade pasta",
      location: "Brooklyn, NY",
      website: "https://example.com/casey",
    )
  end

  before do
    create(:event_attendance, user: user, event: event)
    create(:event_attendance, user: other, event: event)
    create(:user_hobby, user: user)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
    follow_redirect! # land on /dashboard
  end

  after { clear_github_auth }

  describe "GET /profiles/:username" do
    it "returns 200" do
      get profile_path(other.username)
      expect(response).to have_http_status(:ok)
    end

    it "renders the profile fields" do
      get profile_path(other.username)
      expect(response.body)
        .to include("Casey Profile", "Brooklyn, NY", "loves bouldering and homemade pasta")
    end

    it "renders the GitHub icon link from the username" do
      get profile_path(other.username)
      expect(response.body).to include("https://github.com/casey")
    end

    it "renders the website icon link when present" do
      get profile_path(other.username)
      expect(response.body).to include("https://example.com/casey")
    end

    it "renders the hobbies as links to the hobby page" do
      hobby = create(:hobby, name: "bouldering")
      create(:user_hobby, user: other, hobby: hobby)

      get profile_path(other.username)
      expect(response.body).to include("bouldering").and include(hobby_path(hobby))
    end

    it "renders the empty hobbies state when the profile has none" do
      get profile_path(other.username)
      expect(response.body).to include("No hobbies listed yet.")
    end

    it "404s for an unknown username" do
      get profile_path(username: "nobody")
      expect(response).to have_http_status(:not_found)
    end

    it "redirects unauthenticated requests to root" do
      delete sign_out_path
      get profile_path(other.username)
      expect(response).to redirect_to(root_path)
    end

    it "renders hobbies without the Shared-with-you split on your own profile", :aggregate_failures do
      create(:user_hobby, user: user, hobby: create(:hobby, name: "bouldering"))

      get profile_path(user.username)
      expect(response.body).not_to include("Shared with you")
      expect(response.body).to include("bouldering")
    end
  end
end
