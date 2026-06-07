# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Events" do
  let(:user) { create(:user) }
  let!(:event) { create(:event) }

  before do
    create(:user_hobby, user: user)
    create(:event_attendance, user:, event:)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
    follow_redirect! # land on /dashboard
  end

  after { clear_github_auth }

  describe "GET /events" do
    it "returns 200" do
      get events_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /events/:id" do
    it "returns 200" do
      get event_path(event)
      expect(response).to have_http_status(:ok)
    end

    it "404s for an unknown event id" do
      get event_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
