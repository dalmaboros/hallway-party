# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubUserSyncService do
  let(:auth_hash) { github_auth_hash }

  describe ".call" do
    context "when the user does not exist" do
      let(:expected_attributes) do
        {
          provider: "github",
          uid: "12345",
          username: "octocat",
          name: "Mona Octocat",
          email: "mona@github.com",
          avatar_url: "https://example.com/avatar.png",
          location: "San Francisco",
          pronouns: "she/her",
          bio: "Cat-themed mascot.",
          website: "https://octocat.example",
          twitter_url: "https://twitter.com/octocat",
        }
      end

      it "creates a new user" do
        expect { described_class.call(auth_hash) }.to change(User, :count).by(1)
      end

      it "populates attributes from the auth hash" do
        user = described_class.call(auth_hash)

        expect(user).to have_attributes(expected_attributes)
      end

      it "falls back to username when GitHub name is blank" do
        auth_hash.info.name = nil
        user = described_class.call(auth_hash)
        expect(user.name).to eq("octocat")
      end

      it "handles missing raw_info gracefully" do
        auth_hash.extra = nil
        user = described_class.call(auth_hash)
        expect(user.location).to be_nil
      end

      it "handles missing email" do
        auth_hash.info.email = nil
        user = described_class.call(auth_hash)
        expect(user.email).to be_nil
      end

      it "leaves twitter_url blank when GitHub has no twitter_username" do
        auth_hash.extra.raw_info.twitter_username = nil
        user = described_class.call(auth_hash)
        expect(user.twitter_url).to be_nil
      end
    end

    context "when the user already exists" do
      let!(:existing_user) do
        create(:user, provider: "github", uid: "12345", name: "Old Name", bio: "Edited bio")
      end

      it "does not create a new user" do
        expect { described_class.call(auth_hash) }.not_to change(User, :count)
      end

      it "returns the existing user without overwriting attributes" do
        user = described_class.call(auth_hash)

        expect(user).to eq(existing_user)
      end
    end
  end
end
