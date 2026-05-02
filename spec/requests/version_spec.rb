# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Version" do
  let(:revision_path) { Rails.root.join("REVISION") }
  let(:build_time_path) { Rails.root.join("BUILD_TIME") }

  after do
    File.delete(revision_path) if File.exist?(revision_path)
    File.delete(build_time_path) if File.exist?(build_time_path)
  end

  describe "GET /version" do
    context "without deploy metadata files (local dev)" do
      it "returns 200" do
        get "/version"
        expect(response).to have_http_status(:ok)
      end

      it "renders the dev fallback message" do
        get "/version"
        expect(response.body).to include("running outside of a CI deploy")
      end
    end

    context "with deploy metadata files present (deployed)" do
      let(:sha) { "abc1234567890abcdef1234567890abcdef12345" }
      let(:build_time) { "2026-05-02T18:30:00Z" }

      before do
        File.write(revision_path, "#{sha}\n")
        File.write(build_time_path, "#{build_time}\n")
      end

      it "returns 200" do
        get "/version"
        expect(response).to have_http_status(:ok)
      end

      it "shows the short SHA" do
        get "/version"
        expect(response.body).to include(sha.first(7))
      end

      it "links the SHA to the GitHub commit" do
        get "/version"
        expect(response.body).to include(
          %(href="https://github.com/dalmaboros/hallway-party/commit/#{sha}"),
        )
      end

      it "shows the build time" do
        get "/version"
        expect(response.body).to include(build_time)
      end

      it "does not render the dev fallback message" do
        get "/version"
        expect(response.body).not_to include("running outside of a CI deploy")
      end
    end

    it "is reachable without signing in" do
      # /version skips authentication so anyone (e.g. uptime checks, the
      # maintainer on a fresh browser) can verify what's deployed. A 200 here
      # is the proof — the unauthenticated default would redirect to root.
      get "/version"
      expect(response).to have_http_status(:ok)
    end
  end
end
