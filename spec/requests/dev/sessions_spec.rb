# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dev::Sessions" do
  # The dev sign-in routes are conditionally registered in routes.rb
  # (`if Rails.env.development?`). In any other environment (test included)
  # the routes must not exist — defense against the dev sign-in ever leaking
  # into a non-development environment.

  describe "GET /dev/sign_in" do
    it "is not routable outside of development" do
      get "/dev/sign_in"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /dev/sign_in_as/:username" do
    it "is not routable outside of development" do
      post "/dev/sign_in_as/anyone"
      expect(response).to have_http_status(:not_found)
    end
  end
end
