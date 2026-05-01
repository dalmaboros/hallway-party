# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Hobbies" do
  let(:user) { create(:user) }
  let!(:event) { create(:event, :upcoming) }
  let(:hobby) { create(:hobby, name: "bouldering") }

  before do
    create(:event_attendance, user: user, event: event)
    create(:user_hobby, user: user, hobby: hobby)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback"
    follow_redirect! # land on /dashboard so the welcome flash doesn't leak into later assertions
  end

  after { clear_github_auth }

  describe "GET /hobbies/:id" do
    it "returns 200" do
      get hobby_path(hobby)
      expect(response).to have_http_status(:ok)
    end

    it "shows the hobby and event in the heading" do
      get hobby_path(hobby)
      expect(response.body).to include("bouldering").and include(event.name)
    end

    it "lists other attendees who share the hobby" do
      sharer = create(:user, name: "Sharer Person")
      create(:event_attendance, user: sharer, event: event)
      create(:user_hobby, user: sharer, hobby: hobby)

      get hobby_path(hobby)
      expect(response.body).to include("Sharer Person")
    end

    it "does not list the current user even though they have the hobby" do
      get hobby_path(hobby)
      expect(response.body).not_to include(user.name)
    end

    it "does not list attendees of the event who lack the hobby" do
      other_attendee = create(:user, name: "Other Attendee")
      create(:event_attendance, user: other_attendee, event: event)
      create(:user_hobby, user: other_attendee, hobby: create(:hobby, name: "knitting"))

      get hobby_path(hobby)
      expect(response.body).not_to include("Other Attendee")
    end

    it "does not list users with the hobby who aren't attending the event" do
      outsider = create(:user, name: "Outside Person")
      create(:user_hobby, user: outsider, hobby: hobby)

      get hobby_path(hobby)
      expect(response.body).not_to include("Outside Person")
    end

    it "shows the empty state when no other attendees share the hobby" do
      get hobby_path(hobby)
      expect(response.body).to include("be the conversation-starter")
    end

    it "404s for an unknown hobby id" do
      get hobby_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
