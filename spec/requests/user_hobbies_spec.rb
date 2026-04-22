# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserHobbies" do
  let(:user) { create(:user) }
  let!(:featured) { create(:event, :upcoming) }

  before do
    create(:event_attendance, user: user, event: featured)
    stub_github_auth(uid: user.uid)
    get "/auth/github/callback" # sign in
  end

  after { clear_github_auth }

  describe "POST /user_hobbies" do
    context "with a new hobby name" do
      it "creates a new Hobby row" do
        expect do
          post user_hobbies_path, params: { name: "snowboarding" }
        end.to change(Hobby, :count).by(1)
      end

      it "attaches it to the current user" do
        expect do
          post user_hobbies_path, params: { name: "snowboarding" }
        end.to change { user.user_hobbies.count }.by(1)
      end

      it "enqueues the embedding job for the new hobby" do
        expect do
          post user_hobbies_path, params: { name: "snowboarding" }
        end.to have_enqueued_job(GenerateHobbyEmbeddingJob)
      end

      it "redirects back to the hobbies onboarding step" do
        post user_hobbies_path, params: { name: "snowboarding" }
        expect(response).to redirect_to(onboarding_hobbies_path)
      end
    end

    context "with an existing hobby name" do
      let!(:existing) { create(:hobby, name: "knitting") }

      it "does not create a duplicate Hobby" do
        expect do
          post user_hobbies_path, params: { name: "knitting" }
        end.not_to change(Hobby, :count)
      end

      it "attaches the existing hobby to the current user" do
        post user_hobbies_path, params: { name: "knitting" }
        expect(user.hobbies).to include(existing)
      end

      it "does not enqueue the embedding job" do
        expect do
          post user_hobbies_path, params: { name: "knitting" }
        end.not_to have_enqueued_job(GenerateHobbyEmbeddingJob)
      end
    end

    context "with a programming-related hobby name" do
      it "does not create the Hobby" do
        expect do
          post user_hobbies_path, params: { name: "Ruby" }
        end.not_to change(Hobby, :count)
      end

      it "flashes the tongue-in-cheek error message" do
        post user_hobbies_path, params: { name: "Ruby" }
        expect(flash[:alert]).to include("that's not what we're here for")
      end
    end

    context "with a blank name" do
      it "does not create a Hobby" do
        expect do
          post user_hobbies_path, params: { name: "   " }
        end.not_to change(Hobby, :count)
      end

      it "flashes a helpful message" do
        post user_hobbies_path, params: { name: "" }
        expect(flash[:alert]).to eq("Please enter a hobby.")
      end
    end
  end

  describe "DELETE /user_hobbies/:id" do
    let(:first_hobby) { create(:hobby, name: "knitting") }
    let(:second_hobby) { create(:hobby, name: "hiking") }
    let(:removable) { create(:user_hobby, user: user, hobby: second_hobby) }

    before do
      create(:user_hobby, user: user, hobby: first_hobby)
      removable # force creation of the removable join row
    end

    it "removes the UserHobby join row" do
      expect do
        delete user_hobby_path(removable)
      end.to change { user.user_hobbies.count }.by(-1)
    end

    it "does not destroy the Hobby itself" do
      expect do
        delete user_hobby_path(removable)
      end.not_to change(Hobby, :count)
    end

    it "refuses to remove the user's last hobby" do
      delete user_hobby_path(removable)
      last = user.user_hobbies.first

      expect do
        delete user_hobby_path(last)
      end.not_to change { user.user_hobbies.count }
    end
  end
end
