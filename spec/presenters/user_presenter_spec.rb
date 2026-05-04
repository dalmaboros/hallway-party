# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPresenter do
  describe "#initials" do
    let(:presenter) { described_class.new(build(:user, name: name)) }

    context "with a two-name user" do
      let(:name) { "Mona Octocat" }

      it "returns first+last capitalized initials" do
        expect(presenter.initials).to eq("MO")
      end
    end

    context "with a one-name user" do
      let(:name) { "Mona" }

      it "returns the single capitalized initial" do
        expect(presenter.initials).to eq("M")
      end
    end

    context "with three or more name parts" do
      let(:name) { "Jose Maria Octocat" }

      it "returns first+last initials" do
        expect(presenter.initials).to eq("JO")
      end
    end

    context "with a blank name" do
      let(:name) { "" }

      it "returns an empty string" do
        expect(presenter.initials).to eq("")
      end
    end

    context "with a lowercase name" do
      let(:name) { "mona octocat" }

      it "uppercases the initials" do
        expect(presenter.initials).to eq("MO")
      end
    end
  end

  describe "#avatar_color_class" do
    let(:user) { build(:user, username: "user") }
    let(:presenter) { described_class.new(user) }

    it "returns one of the AVATAR_BG_CLASSES" do
      expect(described_class::AVATAR_BG_CLASSES).to include(presenter.avatar_color_class)
    end

    it "is deterministic for the same username" do
      expect(presenter.avatar_color_class).to eq(described_class.new(user).avatar_color_class)
    end

    it "differs for different usernames that hash differently" do
      presenter2 = described_class.new(build(:user, username: "squiddog"))
      expect(presenter.avatar_color_class).not_to eq(presenter2.avatar_color_class)
    end
  end
end
