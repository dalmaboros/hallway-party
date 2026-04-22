# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication" do
  before { stub_github_auth }
  after  { clear_github_auth }

  describe "signing in via GitHub" do
    it "redirects to the dashboard" do
      get "/auth/github/callback"
      expect(response).to redirect_to("/dashboard")
    end

    it "sets a welcome flash" do
      get "/auth/github/callback"
      expect(flash[:notice]).to eq("Welcome, Mona Octocat!")
    end

    it "signs the user in" do
      get "/auth/github/callback"
      expect(session[:user_id]).to eq(User.last.id)
    end

    it "does not create a duplicate user on subsequent sign-ins" do
      get "/auth/github/callback"
      expect { get "/auth/github/callback" }.not_to change(User, :count)
    end
  end

  describe "signing out" do
    before { get "/auth/github/callback" }

    it "redirects to root" do
      delete sign_out_path
      expect(response).to redirect_to(root_path)
    end

    it "clears the session" do
      delete sign_out_path
      expect(session[:user_id]).to be_nil
    end
  end

  describe "protected routes" do
    it "redirects to root when not signed in" do
      get "/onboarding"
      expect(response).to redirect_to(root_path)
    end

    it "allows access when signed in" do
      get "/auth/github/callback"
      get "/onboarding"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "auth failure" do
    it "redirects to root" do
      get "/auth/failure", params: { message: "invalid_credentials" }
      expect(response).to redirect_to(root_path)
    end

    it "sets a failure flash" do
      get "/auth/failure", params: { message: "invalid_credentials" }
      expect(flash[:alert]).to include("Sign-in failed")
    end
  end
end
