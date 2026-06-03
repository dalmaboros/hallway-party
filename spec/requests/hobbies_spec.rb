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

    it "shows the hobby name in the heading" do
      get hobby_path(hobby)
      expect(response.body).to include("bouldering")
    end

    it "lists other users who share the hobby" do
      sharer = create(:user, name: "Sharer Person")
      create(:user_hobby, user: sharer, hobby: hobby)

      get hobby_path(hobby)
      expect(response.body).to include("Sharer Person")
    end

    it "does not list the current user even though they have the hobby" do
      get hobby_path(hobby)
      expect(response.body).not_to include(user.name)
    end

    it "does not list users who lack the hobby" do
      other_user = create(:user, name: "Other Person")
      create(:user_hobby, user: other_user, hobby: create(:hobby, name: "knitting"))

      get hobby_path(hobby)
      expect(response.body).not_to include("Other Person")
    end

    it "lists users with the hobby regardless of event attendance" do
      outsider = create(:user, name: "Outside Person")
      create(:user_hobby, user: outsider, hobby: hobby)

      get hobby_path(hobby)
      expect(response.body).to include("Outside Person")
    end

    it "shows the empty state when no other users share the hobby" do
      get hobby_path(hobby)
      expect(response.body).to include("be the conversation-starter")
    end

    it "404s for an unknown hobby id" do
      get hobby_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "the membership toggle" do
    it "offers to add a hobby the user doesn't have", :aggregate_failures do
      unowned = create(:hobby, name: "surfing")
      get hobby_path(unowned)
      expect(response.body).to include("Add to my hobbies")
      expect(response.body).not_to include("One of your hobbies")
    end

    it "marks a hobby the user has and offers to remove it when they have others", :aggregate_failures do
      create(:user_hobby, user: user, hobby: create(:hobby, name: "surfing"))
      get hobby_path(hobby)
      expect(response.body).to include("One of your hobbies")
      expect(response.body).to include("Remove from my hobbies")
      expect(response.body).not_to include("only hobby")
    end

    it "marks the user's only hobby but blocks removing it", :aggregate_failures do
      get hobby_path(hobby)
      expect(response.body).to include("One of your hobbies")
      expect(response.body).to include("only hobby")
      expect(response.body).not_to include("Remove from my hobbies")
    end
  end
end
